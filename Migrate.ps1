#reauires -version 5.1

# create a new class-based DSC module structure from
# and existing MOF based DSC Resource

# .\Migrate.ps1 -Name timezone  -module @{ModuleName="computermanagementdsc";requiredVersion="8.5.0"} -DestinationPath d:\temp\xtimezone -Verbose
# .\Migrate.ps1 -Name xhotfix -Module xwindowsupdate -DestinationPath d:\temp\xhot
#  .\Migrate.ps1 -Name addomain  -module @{ModuleName="ActiveDirectorydsc";requiredVersion="6.2.0"} -DestinationPath d:\temp\xADDomain

Param(
    [Parameter(Mandatory, HelpMessage = "The name of the DSC Resource")]
    [string]$Name,
    [Parameter(Mandatory, HelpMessage = "The name of the module for the DSC resource. Use fully-qualified name to specify a version.")]
    [object]$Module,
    [Parameter(Mandatory, HelpMessage = "The destination path for the new module, including the new module name.")]
    [string]$DestinationPath,
    [version]$NewVersion = "0.1.0"
)
Import-Module $psscriptroot\DSCResourceMigration.psd1 -Force

#Create new directory structure
Write-Verbose "Creating a module structure $DestinationPath"
$subFolders = "docs", "en-us", "functions", "tests", "samples"

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

#create psm1 with class definition
Write-Verbose "Converting MOF for $name from to Class"
$newName = Split-Path -Path $DestinationPath -Leaf
$rootModule = Join-Path -Path $DestinationPath -ChildPath "$newname.psm1"
#get the source module root path to check for supporting modules
if ($module -is [string]) {
    $modroot = Get-Module -name $Module -ListAvailable | Split-Path
}
else {
    $modroot = Get-Module  -fullyqualifiedName $Module -ListAvailable | Split-Path
}

Write-Verbose "Creating $rootModule"
New-ClassDefinition -name $name -module $module | Out-File -FilePath $rootModule

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
    $fpath = Join-Path -Path $DestinationPath -ChildPath "functions\$($fun.name).ps1"
    Write-Verbose "Exporting $fpath"
    $fun.Extent.text | Out-File -FilePath $fpath -Force
}

Write-Verbose "Adding non-function code to the psm1 file"
$other | Where-Object { $_.extent.text -notmatch "Export-ModuleMember|function" } |
    ForEach-Object {
        $_.Extent.text | Out-File -FilePath $rootModule -Append
    }

#dot source functions
@"
#dot source supporting functions
Get-ChildItem `$PSscriptroot\functions\*.ps1 | Foreach-Object { . .`$_.fullname}

"@ | Out-File -FilePath $rootModule -Append

#create manifest
$manifestPath = Join-Path -Path $DestinationPath -ChildPath "$newname.psd1"
Write-Verbose "Creating manifest $manifestpath"
New-ModuleManifest -Path $manifestPath -RootModule "$newname.psm1" -DscResourcesToExport $Name -ModuleVersion $newversion

#copy existing supporting modules if found
Write-Verbose "Testing $modroot for a Modules folder"
if (Test-Path "$modroot\modules" ) {
    Write-Verbose "Copying supporting modules"
    Copy-Item -Path $modroot\modules -Destination $DestinationPath -Container -Force -Recurse
}

#create a copy of the original schema.mof
Write-Verbose "Creating a copy of the original schema.mof"
$mofPath = Get-SchemaMofPath -name $Name -module $module
Copy-Item -Path $mofPath -Destination $DestinationPath

Write-Verbose "Migration complete. Open $DestinationPath in your editor to continue."