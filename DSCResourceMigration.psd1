#
# Module manifest for DSCResourceMigration
#

@{
    RootModule           = 'DSCResourceMigration.psm1'
    ModuleVersion        = '1.0.0'
    CompatiblePSEditions = 'Core'
    GUID                 = '09763485-4b89-4325-959b-2bed47354905'
    Author               = 'Jeff Hicks'
    CompanyName          = 'JDH Information Technology Solutions, Inc.'
    Copyright            = '(c) 2024-2025 JDH Information Technology Solutions, Inc.'
    Description          = 'A PowerShell module to convert script-based DSC resources to class-based resources. Code in this module should considered proof-of-concept.'
    PowerShellVersion    = '5.1'
    RequiredModules      = @(@{ ModuleName = 'PSDesiredStateConfiguration'; RequiredVersion = '2.0.7' })
    FunctionsToExport    = @(
        'Get-SchemaMofProperty',
        'Get-FunctionName',
        'Get-DSCResourceFunction',
        'Get-DSCHelperFunction',
        'Convert-Mof',
        'Get-AST',
        'Convert-VariableReference',
        'Get-SchemaMofPath',
        'Convert-SchemaMofProperty',
        'New-DSCClassDefinition',
        'New-DSCEnum'
    )
    CmdletsToExport      = ''
    VariablesToExport    = ''
    AliasesToExport      = ''
    PrivateData          = @{
        PSData = @{
            Tags                       = @('DSC', 'DesiredStateConfiguration', 'DSCResource')
            LicenseUri                 = 'https://github.com/jdhitsolutions/DSCResourceMigration/blob/main/License.txt'
            ProjectUri                 = 'https://github.com/jdhitsolutions/DSCResourceMigration'
            # IconUri = ''
            #ReleaseNotes = ''
            RequireLicenseAcceptance   = $false
            ExternalModuleDependencies = 'PSDesiredStateConfiguration'
        }
    }
}
