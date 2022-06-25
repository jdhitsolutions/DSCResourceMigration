#
# Module manifest for module 'DSCResourceMigration'

@{

    # Script module or binary module file associated with this manifest.
    RootModule           = 'DSCResourceMigration.psm1'

    # Version number of this module.
    ModuleVersion        = '0.7.0'

    # Supported PSEditions
    CompatiblePSEditions = 'Desktop','Core'

    # ID used to uniquely identify this module
    GUID                 = '09763485-4b89-4325-959b-2bed47354905'

    # Author of this module
    Author               = 'Jeff Hicks'

    # Company or vendor of this module
    CompanyName          = 'JDH Information Technology Solutions, Inc.'

    # Copyright statement for this module
    Copyright            = '(c) 2022 JDH Information Technology Solutions, Inc.'

    # Description of the functionality provided by this module
    Description          = 'A PowerShell module to convert script-based DSC resources to class-based resources. Code in this module should considered proof-of-concept.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion    = '5.1'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @( @{ ModuleName="PSDesiredStateConfiguration";RequiredVersion="2.0.5"})

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport    = 'Get-SchemaMofProperty', 'Get-FunctionName', 'Get-DSCResourceFunction',
    'Get-DSCHelperFunction', 'Convert-Mof', 'Get-AST', 'Convert-VariableReference','Get-SchemaMofPath',
    'Convert-SchemaMofProperty','New-ClassDefinition','New-DSCEnum'

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport      = ''

    # Variables to export from this module
    VariablesToExport    = ''

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport      = ''

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            # ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

            # Prerelease string of this module
            # Prerelease = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false

            # External dependent modules of this module
            # ExternalModuleDependencies = @()

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}

