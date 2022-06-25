# DSC Resource Migration Accelerator

This is a PowerShell module to help authors migrate __script-based__ DSC resources to class-based resources. The tooling in this module is not designed as a completely hands-free experience. DSC Resource authors should consider the tools in this module as *accelerators* for the migration process.

The DSC Resource module to be converted needs to be installed on your computer.

Code in this module should considered proof-of-concept and work-in-progress.

## Requirements

The commands in this module rely on `Get-DSCResource` from the  `PSDesiredStateConfiguration` module. In Windows PowerShell under v1.1 of the module, you can run a command like `Get-DSCResource xhotfix`. But in PowerShell 7 using the latest version of `PSDesiredStateConfiguration` you need to include the module name.

```powershell
Get-DSCResource -name xhotfix -module xWindowsUpdate
```

As long as any code in this module that invokes `Get-DSCResource`, there shouldn't be any problem. The `DSCResourceMigration` module has a dependency on `@{ModuleName="PSDesiredStateConfiguration";RequiredVersion="2.0.5"}`.

## Demos

The current demo script, `demo-4.ps1`, can be run from the root of this module. Specify the name of a DSC Resource and its module. The output is code that could be inserted into a new `.psm1` file. It would also not be difficult to redirect different sections to different files.

```powershell
PS C:\scripts\DSCResourceMigration>.\demo-4 -Name timezone -Module @{ModuleName="computermanagementdsc";RequiredVersion="8.5.0"} | Set-Clipboard
```

Paste the output into VS Code. Note that this resource is using the `Return` keyword in their MOF-based code so this conversion requires very little in the way of additional coding. But this is not true for other resources.

```powershell
[DSCResource()]
Class DSC_TimeZone {
    [DscProperty(Key)]
    # Specifies the resource is a single instance, the value must be 'Yes'.
    [String]$IsSingleInstance

    [DscProperty(Mandatory)]
    [String]$ResourceId

    [DscProperty(Mandatory)]
    [String]$ModuleName

    [DscProperty(Mandatory)]
    [String]$ModuleVersion

    [DscProperty(Mandatory)]
    # Specifies the TimeZone.
    [String]$TimeZone

    [DscProperty()]
    [String]$SourceInfo

    [DscProperty()]
    [String[]]$DependsOn

    [DscProperty()]
    [String]$ConfigurationName

    [DscProperty()]
    [PSCredential]$PsDscRunAsCredential

    [DSC_TimeZone] Get() {
        # TODO :Insert RETURN keyword
        # TODO: Need to change non-property variables to script scope
        Write-Verbose -Message ($script:localizedData.GettingTimeZoneMessage)
        $currentTimeZone = Get-TimeZoneId
        $returnValue = @{
            IsSingleInstance = 'Yes'
            TimeZone         = $currentTimeZone
        }
        return $returnValue

    } #close Get method

    [void] Set() {
        $currentTimeZone = Get-TimeZoneId
        if ($currentTimeZone -ne $this.TimeZone) {
            Write-Verbose -Message ($script:localizedData.SettingTimeZoneMessage)
            Set-TimeZoneId -TimeZone $this.TimeZone
        }
        else {
            Write-Verbose -Message ($script:localizedData.TimeZoneAlreadySetMessage -f $this.TimeZone)
        }

    } #close Set method

    [Bool] Test() {
        Write-Verbose -Message ($script:localizedData.TestingTimeZoneMessage)
        return Test-TimeZoneId -TimeZoneId $this.TimeZone

    } #close Test method

} #close class

$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'
Import-Module -Name (Join-Path -Path $modulePath `
        -ChildPath (Join-Path -Path 'ComputerManagementDsc.Common' `
            -ChildPath 'ComputerManagementDsc.Common.psm1'))
Import-Module -Name (Join-Path -Path $modulePath -ChildPath 'DscResource.Common')
$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'
<#
original schema.mof
[ClassVersion("1.0.0.0"), FriendlyName("TimeZone")]
class DSC_TimeZone : OMI_BaseResource
{
    [Key, Description("Specifies the resource is a single instance, the value must be 'Yes'."), ValueMap{"Yes"}, Values{"Yes"}] String IsSingleInstance;
    [Required, Description("Specifies the TimeZone.")] String TimeZone;
};
#>
```

The demonstration is only converting a single DSC resource from a module but it shouldn't be difficult to scale out depending on design decisions. See below.

### Migrate.ps1

You will also find `Migrate.ps1`. This is a more full-featured proof-of-concept.

```powershell
.\Migrate.ps1 -Name timezone  -module @{ModuleName="computermanagementdsc";requiredVersion="8.5.0"} -DestinationPath d:\temp\xtimezone -Verbose
```

With this script you specify the path for the new module. The script will:

+ Create a directory structure
+ Generate a class-based psm1 file, along with other non-function code.
+ Export non-targetresource functions to separate files under a functions subfolder
+ Copy the `Modules` directory from the source module root to the target destination. This should help mitigate the child module issue.
+ Create a module manifest with the exported DSC resource.

## Blockers

These are issues that prevent code in this module from converting seamlessly, i.e. without any user intervention.

+ The class methods need to use the `Return` keyword. I can't find a consistent technique  using the AST to identify the line of code writing the `Get` result to the pipeline.
+ External variable references need to be revised to use `$script:`. For example, many Microsoft resources use localized message data. This is referred to in `$LocalizedData`. When used in a class method it needs to be `$script:LocalizedData`. In my testing, *some* DSC resources are already doing this and require no updates.

Regardless of resolving any of these blockers, I would argue that the resource owner review and validate the migration process. The resource may be using deprecated PowerShell cmdlets, or there may be newer cmdlets and parameters. There is also no way to migrate Pester tests. Those may need to be upgraded to reflect the change to a class-based resource as well as migrating from previous versions of Pester.

## Design Decisions

These are long-term design decisions that will determine what additional tooling this module will require.

+ How do we want to organize multiple classes in a single module? Nested modules? Or is it one resource per module?
+ Do we need to handle multiple versions of a DSC Resource module.
+ How do we manage friendly name vs real name for the class? There is no way to define a friendly name or alias for a DSC class-based resource.
+ How do we want to layout the new module folder structure?
+ How do we want to handle versioning? In my demo code I am generating a version number that is the next major version.
+ Should we copy old Pester tests included in the original module to the new module? Old Pester tests may need to be re-factored for Pester v5.
+ Should we insert a code block that prevents the module from being loaded to force the author to review and update the new code?
+ Does code signing need to be taken into account?
+ How do we handle module dependencies? For example, the `SMBShare` resource in the `ComputerManagementDSC` module is running `Import-Module -Name (Join-Path -Path $modulePath -ChildPath 'DscResource.Common')`. In my demo `Migrate.ps1` file I can copy the source folders if the original module has a `Modules` sub-folder.

### Last Updated 25 June 2022
