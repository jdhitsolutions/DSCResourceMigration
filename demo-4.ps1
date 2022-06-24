
#4th development pass

# Convert a single resource.
# The output of this script file could be saved to a new .psm1 file

[cmdletbinding()]
Param(
	[string]$Name = "xHotFix",
	#Module parameter needs to support qualified name for versioning
	[object]$Module = "xWindowsUpdate"
)

Import-Module $psscriptroot\DSCResourceMigration.psd1 -Force

Write-Verbose "Converting MOF for $name from to Class"
New-ClassDefinition -name $name -module $module

Write-Verbose "Getting non-TargetResource code"
#get all commands in the psm1 other than the Get/Set/Test functions
#this could be turned into a function
$resource = Get-DscResource -Name $Name -Module $module | Select-Object -first 1
$ast = Get-AST -path $resource.path
$found = $ast.findall({ $args[0] -is [System.Management.Automation.Language.Ast] }, $true)
$h = $found | Group-Object { $_.GetType().Name } -AsHashTable -AsString

$other = $h["NamedBlockAST"][0].statements |
	Where-Object { $_.name -notmatch "[(get)|(set)|(test)]-TargetResource" } |
	Select-Object extent

$other | Where-Object { $_.extent.text -notmatch "Export-ModuleMember" } |
	ForEach-Object {
		$_.Extent.text
	}

#append original mof
# TODO: get matching definition when the mof might have multiple
@"
<#
original schema.mof
"@
Get-SchemaMofPath -name $name -module $module -content
"#>"

