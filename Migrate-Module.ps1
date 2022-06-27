#reauires -version 5.1

# A proof-of-concept script to migrate all resources from a MOF-based DSC module
# to a class-based set of DSC resources. Each resource will be exported to a separate
# file under a Classes folder.

# .\Migrate-module.ps1 -Module xwindowsupdate -DestinationPath d:\temp\WindowsUpdateDsc

Param(
    [Parameter(Mandatory, HelpMessage = "The name of the module for the DSC resource. Use fully-qualified name to specify a version.")]
    [object]$Module,
    [Parameter(Mandatory, HelpMessage = "The destination path for the new module, including the new module name.")]
    [string]$DestinationPath,
    [version]$NewVersion = "0.1.0"
)

Import-Module $psscriptroot\DSCResourceMigration.psd1 -Force

$newName = Split-Path -Path $DestinationPath -Leaf
$rootModule = Join-Path -Path $DestinationPath -ChildPath "$newname.psm1"

#get the source module root path to check for supporting modules
if ($module -is [string]) {
    $modroot = Get-Module -Name $Module -ListAvailable -OutVariable mod | Split-Path
}
else {
    $modroot = Get-Module -FullyQualifiedName $Module -ListAvailable -OutVariable mod | Split-Path
}

if (-Not $modroot) {
    Throw "Failed to find the module."
    Return
}
else {
    Write-Verbose "Using source module root $modroot"
}

#get DSCResources from the module
Write-Verbose "Checking $($mod.path) for DscResourcesToExport"
$import = Import-PowerShellDataFile -path $mod.path
if ($import.DscResourcesToExport) {
    $resources = $import.DscResourcesToExport
}
else {
    Write-Verbose "Checking for resources under $modroot"
    if (Test-Path $modroot\DscResources ) {
        $resources = (Get-ChildItem -Path $modroot\DscResources -ErrorAction stop).name
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
foreach ($sub in $subfolders) {
    if (Test-Path (Join-Path -Path $DestinationPath -ChildPath $sub)) {
        Write-Verbose "Skipping $sub.name"
    }
    else {
        New-Item -ItemType Directory -Path $DestinationPath -Name $sub
    }
}

#copy existing supporting modules if found
Write-Verbose "Testing $modroot for a Modules folder"
if (Test-Path "$modroot\modules" ) {
    Write-Verbose "Copying supporting modules"
    Copy-Item -Path $modroot\modules -Destination $DestinationPath -Container -Force -Recurse
}

Write-Verbose "Creating $rootModule"
#dot source the class files to the psm1 file
@"
Get-Childitem -path `$PSScriptRoot\classes  |
Foreach-Object {. `$_.fullname}
"@ | Out-File -FilePath $rootModule

#convert each resource into a class in its own folder
#each migrated class should be as complete and self-contained as possible,
#even though there may be duplicate helper functions
foreach ($Name in $Resources ) {
    Write-Verbose "Converting MOF for $name from to Class"
    Write-Verbose "Creating a folder for the class"
    $classFolder = New-Item -Path "$DestinationPath\Classes" -Name $Name -ItemType Directory -Force
    $classFile = Join-Path -Path $classFolder.fullname -ChildPath "$name.ps1"
    $classFunctions = New-Item -Name functions -Path $classFolder.fullName -ItemType Directory -Force

    New-ClassDefinition -name $name -module $module | Out-File -FilePath $classFile

    #export helper functions to individual files under .\functions
    Write-Verbose "Getting non-TargetResource code"
    #get all commands in the psm1 other than the Get/Set/Test functions
    #this could be turned into a function
    $resource = Get-DscResource -Name $Name -Module $module | Select-Object -First 1
    $ast = Get-AST -path $resource.path
    $found = $ast.findall({ $args[0] -is [System.Management.Automation.Language.Ast] }, $true)
    $h = $found | Group-Object { $_.GetType().Name } -AsHashTable -AsString

    $other = $h["NamedBlockAST"][0].statements |
    Where-Object { $_.name -notmatch "[(get)|(set)|(test)]-TargetResource" } |
    Select-Object extent

    #export functions to separate files
    $funs = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) |
    Where-Object { $_.name -notmatch "targetResource" }
    foreach ($fun in $funs) {
        $fpath = Join-Path -Path $classFunctions.fullname -ChildPath "$($fun.name).ps1"
        Write-Verbose "Exporting $fpath"
        $fun.Extent.text | Out-File -FilePath $fpath -Force
    }

    Write-Verbose "Adding non-function code to the class file"
    "`n# TODO: IF IMPORTING HELPER MODULES YOU MAY NEED TO FIX PATH REFERENCES" | Out-File -FilePath $classfile -Append
    $other | Where-Object { $_.extent.text -notmatch "Export-ModuleMember|function" } |
    ForEach-Object {
        $_.Extent.text | Out-File -FilePath $classfile -Append
    }

    @"

#dot source supporting functions
Get-ChildItem `$PSScriptroot\functions\*.ps1 | Foreach-Object { . `$_.fullname}

"@ | Out-File -FilePath $classfile -Append

    #append  a copy of the original schema.mof to the new class .ps1 file
    Write-Verbose "Creating a copy of the original schema.mof"
    $mofPath = Get-SchemaMofPath -name $Name -module $module
    @"
<#
original shema.mof
$( Get-Content -Path $mofPath | Out-String)
#>
"@  | Out-File -FilePath $classfile -Append

} #foreach resource

#create manifest
$manifestPath = Join-Path -Path $DestinationPath -ChildPath "$newname.psd1"
Write-Verbose "Creating manifest $manifestpath"
New-ModuleManifest -Path $manifestPath -RootModule "$newname.psm1" -DscResourcesToExport $resources -ModuleVersion $newversion

Write-Host "Migration complete. Open $DestinationPath in your editor to continue." -ForegroundColor Green