# DSC Resource Migration Accelerator

[![PSGallery Version](https://img.shields.io/powershellgallery/v/DSCResourceMigration.png?style=for-the-badge&label=PowerShell%20Gallery)](https://www.powershellgallery.com/packages/DSCResourceMigration/) [![PSGallery Downloads](https://img.shields.io/powershellgallery/dt/DSCResourceMigration.png?style=for-the-badge&label=Downloads)](https://www.powershellgallery.com/packages/DSCResourceMigration/)

This is a PowerShell module to help authors migrate __script-based__ DSC resources to class-based resources. The tooling in this module is __not__ designed as a completely hands-free experience. DSC Resource authors should consider the tools in this module as *accelerators* for the migration process.

__*The DSC Resource module to be converted must be installed on your computer*.__

Code in this module should considered __proof-of-concept__ and as an SDK or framework.

## Installation

Install this module from the PowerShell Gallery on the computer where you author DSC resources. This module requires PowerShell 7 and the latest version of the `PSDesiredStateConfiguration` module.

```powershell
Install-PSResource -Name DSCResourceMigration -Force
```

The `PSDesiredStateConfiguration` module will be installed as a dependency.

## Requirements

The commands in this module rely on `Get-DSCResource` from the `PSDesiredStateConfiguration` module. In Windows PowerShell under v1.1 of the module, you can run a command like `Get-DSCResource xHotFix`. But in PowerShell 7 using the latest version of `PSDesiredStateConfiguration` you need to include the module name.

```powershell
Get-DSCResource -name xHotfix -module xWindowsUpdate
```

The `DSCResourceMigration` module has a dependency on `@{ModuleName="PSDesiredStateConfiguration";RequiredVersion="2.0.7}`.

## Demonstration Code

This module contains several demonstration migration scripts. These should be considered proof-of-concept. The scripts are intended to be run from the root of this module.

### Demo-MigrateResource.ps1

The current demo script, [`Demo-MigrateResource.ps1`](Demo-MigrateResource.ps1), can be run from the root of this module. Specify the name of a DSC Resource and its module. The output is code that could be inserted into a new `.psm1` file. It would also not be difficult to redirect different sections to different files. (*See the migration sample scripts*.)

```powershell
PS C:\scripts\DSCResourceMigration>.\Demo-MigrateResource -Name timezone -Module @{ModuleName="ComputerManagementDSC";RequiredVersion="8.5.0"} | Set-Clipboard
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

### [Migrate.ps1](Migrate.ps1)

You will also find `Migrate.ps1` in the module root folder. This is a more full-featured proof-of-concept.

```powershell
PS C:\Scripts\DSCResourceMigration> .\Migrate.ps1 -Name timezone  -module @{ModuleName="ComputerManagementDSC";requiredVersion="8.5.0"} -DestinationPath d:\temp\xtimezone
PS C:\Scripts\DSCResourceMigration> dir D:\temp\xtimezone\

    Directory: D:\temp\xtimezone

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----           4/16/2025 11:58 AM                docs
d----           4/16/2025 11:58 AM                en-us
d----           4/16/2025 11:58 AM                functions
d----           4/16/2025 11:58 AM                Modules
d----           4/16/2025 11:58 AM                samples
d----           4/16/2025 11:58 AM                tests
-a---           9/13/2021  8:50 AM            326 DSC_TimeZone.schema.mof
-a---           4/16/2025 11:58 AM           4164 xtimezone.psd1
-a---           4/16/2025 11:58 AM           2111 xtimezone.psm1
```

With this script, you specify the path for the new module. The script will:

- Create a directory structure.
- Generate a class-based psm1 file, along with other non-function code.
- Export non-TargetResource functions to separate files under a functions subfolder.
- Copy the `Modules` directory from the source module root to the target destination. This should help mitigate the child module issue.
- Create a module manifest with the exported DSC resource.

### [Migrate-Module.ps1](Migrate-Module.ps1)

This script will migrate an entire MOF-based DSC Resource module to a target location. The script will create a new directory structure. Every DSC resource will be exported to a file under a directory under a module Classes. Supporting functions for each resource will be exported to separate files under each class folder. The idea is to try to make each resource as self-contained as possible.

```powershell
.\Migrate-Module.ps1 -Module xWindowsUpdate -DestinationPath d:\temp\WindowsUpdateDsc
```

The converted module:

```dos
PS C:\> dir D:\temp\WindowsUpdateDsc\ -Recurse

    Directory: D:\temp\WindowsUpdateDsc

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----           4/16/2025  9:28 AM                classes
d----           4/16/2025  9:28 AM                docs
d----           4/16/2025  9:28 AM                en-us
d----           4/16/2025  9:28 AM                functions
d----           4/16/2025  9:28 AM                samples
d----           4/16/2025  9:28 AM                tests
-a---           4/16/2025 11:55 AM           4259 WindowsUpdateDsc.psd1
-a---           4/16/2025 11:54 AM             78 WindowsUpdateDsc.psm1

    Directory: D:\temp\WindowsUpdateDsc\classes

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----           4/16/2025  9:28 AM                MSFT_xMicrosoftUpdate
d----           4/16/2025  9:28 AM                MSFT_xWindowsUpdate
d----           4/16/2025  9:28 AM                MSFT_xWindowsUpdateAgent

    Directory: D:\temp\WindowsUpdateDsc\classes\MSFT_xMicrosoftUpdate

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----           4/16/2025  9:28 AM                functions
-a---           4/16/2025 11:54 AM           3337 MSFT_xMicrosoftUpdate.ps1

    Directory: D:\temp\WindowsUpdateDsc\classes\MSFT_xMicrosoftUpdate\functions

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---           4/16/2025 11:54 AM            136 Write-DeprecatedMessage.ps1

    Directory: D:\temp\WindowsUpdateDsc\classes\MSFT_xWindowsUpdate

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----           4/16/2025  9:28 AM                functions
-a---           4/16/2025 11:55 AM           8492 MSFT_xWindowsUpdate.ps1

    Directory: D:\temp\WindowsUpdateDsc\classes\MSFT_xWindowsUpdate\functions

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---           4/16/2025 11:55 AM            379 New-InvalidArgumentException.p
                                                  s1
-a---           4/16/2025 11:55 AM           1736 Test-StandardArguments.ps1
-a---           4/16/2025 11:55 AM           4347 Test-WindowsUpdatePath.ps1
-a---           4/16/2025 11:55 AM            158 Trace-Message.ps1

    Directory: D:\temp\WindowsUpdateDsc\classes\MSFT_xWindowsUpdateAgent

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----           4/16/2025  9:28 AM                functions
-a---           4/16/2025 11:55 AM          10052 MSFT_xWindowsUpdateAgent.ps1

    Directory:
D:\temp\WindowsUpdateDsc\classes\MSFT_xWindowsUpdateAgent\functions

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---           4/16/2025 11:55 AM            337 Add-WuaService.ps1
-a---           4/16/2025 11:55 AM             92 Get-WuaAu.ps1
-a---           4/16/2025 11:55 AM            475 Get-WuaAuNotificationLevel.ps1
-a---           4/16/2025 11:55 AM            761 Get-WuaAuNotificationLevelInt.
                                                  ps1
-a---           4/16/2025 11:55 AM             67 Get-WuaAuSettings.ps1
-a---           4/16/2025 11:55 AM            355 Get-WuaRebootRequired.ps1
-a---           4/16/2025 11:55 AM           1198 get-WuaSearcher.ps1
-a---           4/16/2025 11:55 AM           2579 Get-WuaSearchString.ps1
-a---           4/16/2025 11:55 AM            106 Get-WuaServiceManager.ps1
-a---           4/16/2025 11:55 AM             94 Get-WuaSession.ps1
-a---           4/16/2025 11:55 AM            100 Get-WuaSystemInfo.ps1
-a---           4/16/2025 11:55 AM           2164 Get-WuaWrapper.ps1
-a---           4/16/2025 11:55 AM            389 Invoke-WuaDownloadUpdates.ps1
-a---           4/16/2025 11:55 AM            381 Invoke-WuaInstallUpdates.ps1
-a---           4/16/2025 11:55 AM            217 Remove-WuaService.ps1
-a---           4/16/2025 11:55 AM            476 Set-WuaAuNotificationLevel.ps1
-a---           4/16/2025 11:55 AM            665 Test-SearchResult.ps1
```

## Blockers

These are several issues that prevent code in this module from converting seamlessly, i.e. without any user intervention.

- The class methods need to use the `Return` keyword. I can't find a consistent technique using the AST to identify the line of code writing the `Get` result to the pipeline.
- External variable references need to be revised to use `$script:`. For example, many Microsoft resources use localized message data. This is referred to in `$LocalizedData`. When used in a class method it needs to be `$script:LocalizedData`. In my testing, *some* DSC resources are already doing this and require no updates.

Regardless of resolving any of these blockers, I would recommend that the resource owner review and validate the migration process. The resource may be using deprecated PowerShell cmdlets, or there may be newer cmdlets and parameters. There is also no way to migrate Pester tests. Those may need to be upgraded to reflect the change to a class-based resource as well as migrating from previous versions of Pester.

## Design Decisions

These are long-term design decisions that will determine what additional tooling this module will require.

- How do we want to organize multiple classes in a single module? Nested modules? Or is it one resource per module?
- Do we need to handle multiple versions of a DSC Resource module?
- How do we manage the friendly name vs the real name for the class? There is no way to define a friendly name or alias for a DSC class-based resource.
- How do we want to lay out the new module folder structure?
- How do we want to handle versioning? In my demo code, I am generating a version number that is the next major version.
- Should we copy the old Pester tests included in the original module to the new module? Old Pester tests may need to be re-factored for Pester v5.
- Should we insert a code block that prevents the module from being loaded to force the author to review and update the new code?
- Does code signing need to be taken into account?
- How do we handle module dependencies? For example, the `SMBShare` resource in the `ComputerManagementDSC` module is running `Import-Module -Name (Join-Path -Path $modulePath -ChildPath 'DscResource.Common')`. In my demo `Migrate.ps1` file I can copy the source folders if the original module has a `Modules` sub-folder.

You are invited to share your ideas in the projects [Discussions](https://github.com/jdhitsolutions/DSCResourceMigration/discussions).