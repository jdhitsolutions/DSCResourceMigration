#requires -version 5.1

# create a new class-based DSC module structure from
# and existing MOF based DSC Resource

# .\Migrate.ps1 -Name timezone  -module @{ModuleName="computermanagementdsc";requiredVersion="8.5.0"} -DestinationPath d:\temp\xtimezone -Verbose
# .\Migrate.ps1 -Name xhotfix -Module xwindowsupdate -DestinationPath d:\temp\xhot
#  .\Migrate.ps1 -Name addomain  -module @{ModuleName="ActiveDirectorydsc";requiredVersion="6.2.0"} -DestinationPath d:\temp\xADDomain

Param(
    [Parameter(Mandatory, HelpMessage = "The name of the DSC Resource")]
    [String]$Name,
    [Parameter(Mandatory, HelpMessage = "The name of the module for the DSC resource. Use fully-qualified name to specify a version.")]
    [object]$Module,
    [Parameter(Mandatory, HelpMessage = "The destination path for the new module, including the new module name.")]
    [String]$DestinationPath,
    [version]$NewVersion = "0.1.0"
)

Import-Module $PSScriptRoot\DSCResourceMigration.psd1 -Force

#Create new directory structure
Write-Verbose "Creating a module structure $DestinationPath"
$subFolders = "docs", "en-us", "functions", "tests", "samples"

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

#create psm1 with class definition
Write-Verbose "Converting MOF for $name from to Class"
$newName = Split-Path -Path $DestinationPath -Leaf
$rootModule = Join-Path -Path $DestinationPath -ChildPath "$newName.psm1"
#get the source module root path to check for supporting modules
if ($module -is [String]) {
    $modRoot = Get-Module -name $Module -ListAvailable | Split-Path
}
else {
    $modRoot = Get-Module -FullyQualifiedName $Module -ListAvailable | Split-Path
}

Write-Verbose "Creating $rootModule"
New-DSCClassDefinition -name $name -module $module | Out-File -FilePath $rootModule

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
    $fPath = Join-Path -Path $DestinationPath -ChildPath "functions\$($fun.name).ps1"
    Write-Verbose "Exporting $fPath"
    $fun.Extent.text | Out-File -FilePath $fPath -Force
}

Write-Verbose "Adding non-function code to the psm1 file"
$other | Where-Object { $_.extent.text -notmatch "Export-ModuleMember|function" } |
    ForEach-Object {
        $_.Extent.text | Out-File -FilePath $rootModule -Append
    }

#dot source functions
@"
#dot source supporting functions
Get-ChildItem `$PSScriptRoot\functions\*.ps1 | ForEach-Object { . .`$_.FullName}

"@ | Out-File -FilePath $rootModule -Append

#create manifest
$manifestPath = Join-Path -Path $DestinationPath -ChildPath "$newName.psd1"
Write-Verbose "Creating manifest $manifestPath"
New-ModuleManifest -Path $manifestPath -RootModule "$newName.psm1" -DscResourcesToExport $Name -ModuleVersion $newversion

#copy existing supporting modules if found
Write-Verbose "Testing $modRoot for a Modules folder"
if (Test-Path "$modRoot\modules" ) {
    Write-Verbose "Copying supporting modules"
    Copy-Item -Path $modRoot\modules -Destination $DestinationPath -Container -Force -Recurse
}

#create a copy of the original schema.mof
Write-Verbose "Creating a copy of the original schema.mof"
$MofPath = Get-SchemaMofPath -name $Name -module $module
Copy-Item -Path $MofPath -Destination $DestinationPath

Write-Verbose "Migration complete. Open $DestinationPath in your editor to continue."
