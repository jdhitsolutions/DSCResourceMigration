# DSC Resource Migration

This is a PowerShell module to convert script-based DSC resources to class-based resources. The DSC Resource module to be converted needs to be installed on your computer.

Code in this module should considered proof-of-concept and work-in-progress.

## Requirements

The commands in this module are intended to run under Windows PowerShell 5.1 and with version 1.1 of the PSDesiredStateConfiguration module.

## Demo

The current demo script, `demo-3.ps1`, can be run from the root of this module. Specify the name of a DSC Resource. The output is code that could be inserted into a new `.psm1` file. It would also not be difficult to redirect different sections to different files.

```powershell
PS C:\scripts\DSCResourceMigration> .\demo-3.ps1 timeZone | Set-Clipboard
WARNING: Failed to find a Write property in C:\Program Files\WindowsPowerShell\Modules\ComputerManagementDsc\8.5.0\DSCResources\DSC_TimeZone\DSC_TimeZone.schema.mof. This may be by design.
WARNING: Failed to find a Read property in C:\Program Files\WindowsPowerShell\Modules\ComputerManagementDsc\8.5.0\DSCResources\DSC_TimeZone\DSC_TimeZone.schema.mof. This may be by design.
```

Paste into VS Code. Note that this resource is using the `Return` keyword in their MOF-based code so this conversion requires very little in the way of additional coding.

```powershell
$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'
Import-Module -Name (Join-Path -Path $modulePath `
        -ChildPath (Join-Path -Path 'ComputerManagementDsc.Common' `
            -ChildPath 'ComputerManagementDsc.Common.psm1'))
Import-Module -Name (Join-Path -Path $modulePath -ChildPath 'DscResource.Common')
$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'
enum IsSingleInstance {
  Yes
}

[DSCResource()]
Class DSC_TimeZone {
[DscProperty(Key)]
# Specifies the resource is a single instance, the value must be 'Yes'.
  [String]$IsSingleInstance

[DscProperty(Mandatory)]
# Specifies the TimeZone.
  [String]$TimeZone

[DSC_TimeZone] Get() {
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
 if ($currentTimeZone -ne $this.TimeZone)
    {
        Write-Verbose -Message ($script:localizedData.SettingTimeZoneMessage)
        Set-TimeZoneId -TimeZone $this.TimeZone
    }
    else
    {
        Write-Verbose -Message ($script:localizedData.TimeZoneAlreadySetMessage -f $this.TimeZone)
    }

} #close Set method

[Bool] Test() {
Write-Verbose -Message ($script:localizedData.TestingTimeZoneMessage)
 return Test-TimeZoneId -TimeZoneId $this.TimeZone

} #close Test method

} #close class

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

## Blockers

These are issues that prevent code in this module from converting seamlessly, i.e. without any user intervention.

+ The class methods need to use the `Return` keyword. I can't find a consistent technique to identify the line of code writing a result to the pipeline.
+ External variable references need to be revised to use `$script:`. For example, many Microsoft resources use localized message data. This is referred to in `$LocalizedData`. When used in a class method it needs to be `$script:LocalizedData`. In my testing, *some* DSC resources are already doing this and require no updates.

Regardless of resolving any of these blockers, I would argue that the resource owner review and validate the migration process. The resource may be using deprecated PowerShell cmdlets, or there may be newer cmdlets and parameters. There is also no way to migrate Pester tests. Those may need to be upgraded to reflect the change to a class-based resource as well as migrating from previous versions of Pester.

## Design Decisions

These are long-term design decisions.

+ How do we want to organize multiple classes in a single module? Nested modules?
+ How do we manage friendly name vs real name for the class? There is no way to define a friendly name or alias for a DSC class-based resource.
+ How do we want to layout the new module folder structure?
+ How do we want to handle versioning? In my demo code I am generating a version number that is the next major version.
+ Should we copy old Pester tests included in the original module to the new module?
+ Should we insert a code block that prevents the module from being loaded to force the author to review and update the new code?
