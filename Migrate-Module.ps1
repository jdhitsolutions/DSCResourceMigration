#requires -version 5.1

# A proof-of-concept script to migrate all resources from a MOF-based DSC module
# to a class-based set of DSC resources. Each resource will be exported to a separate
# file under a Classes folder.

# .\Migrate-module.ps1 -Module xWindowsUpdate -DestinationPath d:\temp\WindowsUpdateDsc

Param(
    [Parameter(Mandatory, HelpMessage = "The name of the module for the DSC resource. Use fully-qualified name to specify a version.")]
    [object]$Module,
    [Parameter(Mandatory, HelpMessage = "The destination path for the new module, including the new module name.")]
    [String]$DestinationPath,
    [version]$NewVersion = "0.1.0"
)

Import-Module $PSScriptRoot\DSCResourceMigration.psd1 -Force

$newName = Split-Path -Path $DestinationPath -Leaf
$rootModule = Join-Path -Path $DestinationPath -ChildPath "$newName.psm1"

#get the source module root path to check for supporting modules
if ($module -is [String]) {
    $modRoot = Get-Module -Name $Module -ListAvailable -OutVariable mod | Split-Path
}
else {
    $modRoot = Get-Module -FullyQualifiedName $Module -ListAvailable -OutVariable mod | Split-Path
}

if (-Not $modRoot) {
    Throw "Failed to find the module."
    Return
}
else {
    Write-Verbose "Using source module root $modRoot"
}

#get DSCResources from the module
Write-Verbose "Checking $($mod.path) for DscResourcesToExport"
$import = Import-PowerShellDataFile -path $mod.path
if ($import.DscResourcesToExport) {
    $resources = $import.DscResourcesToExport
}
else {
    Write-Verbose "Checking for resources under $modRoot"
    if (Test-Path $modRoot\DscResources ) {
        $resources = (Get-ChildItem -Path $modRoot\DscResources -ErrorAction stop).name
    }
    else {
        Throw "Can't determine the location for the DSC Resource source files"
    }
}

#Create new directory structure
Write-Verbose "Creating a module structure $DestinationPath"
$subFolders = "docs", "en-us", "functions", "tests", "samples", "classes"

if (-Not (Test-Path -Path $DestinationPath)) {
    [void](New-Item -ItemType Directory -Path $DestinationPath)
}
foreach ($sub in $subFolders) {
    if (Test-Path (Join-Path -Path $DestinationPath -ChildPath $sub)) {
        Write-Verbose "Skipping $sub.name"
    }
    else {
        New-Item -ItemType Directory -Path $DestinationPath -Name $sub
    }
}

#copy existing supporting modules if found
Write-Verbose "Testing $modRoot for a Modules folder"
if (Test-Path "$modRoot\modules" ) {
    Write-Verbose "Copying supporting modules"
    Copy-Item -Path $modRoot\modules -Destination $DestinationPath -Container -Force -Recurse
}

Write-Verbose "Creating $rootModule"
#dot source the class files to the psm1 file
@"
Get-ChildItem -path `$PSScriptRoot\classes  |
ForEach-Object {. `$_.FullName}
"@ | Out-File -FilePath $rootModule

#convert each resource into a class in its own folder
#each migrated class should be as complete and self-contained as possible,
#even though there may be duplicate helper functions
foreach ($Name in $Resources ) {
    Write-Verbose "Converting MOF for $name from to Class"
    Write-Verbose "Creating a folder for the class"
    $classFolder = New-Item -Path "$DestinationPath\Classes" -Name $Name -ItemType Directory -Force
    $classFile = Join-Path -Path $classFolder.FullName -ChildPath "$name.ps1"
    $classFunctions = New-Item -Name functions -Path $classFolder.FullName -ItemType Directory -Force

    New-DSCClassDefinition -name $name -module $module | Out-File -FilePath $classFile

    #export helper functions to individual files under .\functions
    Write-Verbose "Getting non-TargetResource code"
    #get all commands in the psm1 other than the Get/Set/Test functions
    #this could be turned into a function
    $resource = Get-DscResource -Name $Name -Module $module | Select-Object -First 1
    $ast = Get-AST -path $resource.path
    $found = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.Ast] }, $true)
    $h = $found | Group-Object { $_.GetType().Name } -AsHashTable -AsString

    $other = $h["NamedBlockAST"][0].statements |
    Where-Object { $_.name -notmatch "[(get)|(set)|(test)]-TargetResource" } |
    Select-Object extent

    #export functions to separate files
    $funcs = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) |
    Where-Object { $_.name -notmatch "targetResource" }
    foreach ($fun in $funcs) {
        $fPath = Join-Path -Path $classFunctions.FullName -ChildPath "$($fun.name).ps1"
        Write-Verbose "Exporting $fPath"
        $fun.Extent.text | Out-File -FilePath $fPath -Force
    }

    Write-Verbose "Adding non-function code to the class file"
    "`n# TODO: IF IMPORTING HELPER MODULES YOU MAY NEED TO FIX PATH REFERENCES" | Out-File -FilePath $classFile -Append
    $other | Where-Object { $_.extent.text -notmatch "Export-ModuleMember|function" } |
    ForEach-Object {
        $_.Extent.text | Out-File -FilePath $classFile -Append
    }

    @"

#dot source supporting functions
Get-ChildItem `$PSScriptRoot\functions\*.ps1 | ForEach-Object { . `$_.FullName}

"@ | Out-File -FilePath $classFile -Append

    #append  a copy of the original schema.mof to the new class .ps1 file
    Write-Verbose "Creating a copy of the original schema.mof"
    $MofPath = Get-SchemaMofPath -name $Name -module $module
    @"
<#
original schema.mof
$( Get-Content -Path $MofPath | Out-String)
#>
"@  | Out-File -FilePath $classFile -Append

} #foreach resource

#create manifest
$manifestPath = Join-Path -Path $DestinationPath -ChildPath "$newName.psd1"
Write-Verbose "Creating manifest $manifestPath"
New-ModuleManifest -Path $manifestPath -RootModule "$newName.psm1" -DscResourcesToExport $resources -ModuleVersion $newversion

Write-Host "Migration complete. Open $DestinationPath in your editor to continue." -ForegroundColor Green
