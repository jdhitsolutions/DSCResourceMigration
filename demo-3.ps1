#this should run in windows PowerShell for now.

#Third development pass

#convert a single resource

[cmdletbinding()]
Param($Name = "xHotFix")

Import-Module $psscriptroot\DSCResourceMigration.psd1 -Force
Try {
	Write-Verbose "Getting the most current version of DSC Resource $name"
	$resource = Get-DscResource -Name $name -erroraction stop |
	Sort-Object version -Descending | Select-Object -First 1
}
Catch {
	Throw $_
}

$code = [System.Collections.Generic.list[string]]::New()
$parent = Split-Path $resource.Path
$mofPath = Join-Path $parent -child "$($resource.ResourceType).schema.mof"

#how do we want to handle friendly name vs official class name?

#create a new version number that is the major version + 1
#this could be used in the new module manifest
$newversion = [version]::New($resource.Version.major + 1, 0, 0, 0)

Write-Verbose "Getting non-TargetResource code"
#get all commands in the psm1 other than the Get/Set/Test functions
$ast = Get-AST -path $resource.path
$found = $ast.findall({ $args[0] -is [System.Management.Automation.Language.Ast] }, $true)
$h = $found | Group-Object { $_.GetType().Name } -AsHashTable -AsString

$other = $h["NamedBlockAST"][0].statements |
Where-Object { $_.name -notmatch "[(get)|(set)|(test)]-TargetResource" } |
Select-Object extent

$other | Where-Object { $_.extent.text -notmatch "Export-ModuleMember" } |
ForEach-Object {
	$_.Extent.text | ForEach-Object { $code.Add($_) }
}

Write-Verbose "Converting MOF from $mofpath"
$Mof = Convert-Mof $mofpath

# need to identify enums
$mof.properties.where({ $_.valuemap }).foreach({
		$code.Add("enum $($_.PropertyName) {")
		Foreach ($v in $_.valuemap) {
			$code.Add("  $($v)")
		}
		$code.add("}`n")
	})

$code.Add("[DSCResource()]")
$code.add("Class $($mof.name) {")

#insert properties
<#

DSCType      : Key
PropertyType : String
PropertyName : Path
Description  : Specifies the path that contains the msu file for the hotfix installation.
ValueMap     : {}
#>

Foreach ($p in $mof.properties) {
	Write-Verbose "Processing $($p.PropertyName)"
	$dscProperty = $null
	switch ($p.DSCType) {
		"Key" { $dscProperty = "Key"; break }
		"Required" { $dscProperty = "Mandatory"; break }
		"Read" { $dscProperty = "NotConfigurable"; break }
		"Default" { $dscProperty = "" }
	}
	$code.Add("[DscProperty($dscProperty)]")

	if ($p.ValueMap.count -gt 1) {
		$ptype = "[$($p.PropertyName)]"
	}
	else {
		$ptype = "[$($p.PropertyType)]"
	}
	#insert the description as a comment
	$code.Add("# $($p.Description)")
	$code.Add("  $ptype`$$($p.PropertyName)`n")
}

#parse module file to get method code
#TODO :Insert RETURN keyword
#TODOI: Need to change non-property variables to script scope

$getFun = Get-DSCResourceFunction -Path $resource.path -Name Get-TargetResource
$code.Add("[$($mof.name)] Get() {")
$method = $getFun.Body
foreach ($prop in $resource.properties) {
	$method = Convert-VariableReference -VariableName $prop.name -CodeBlock $method
}
$code.Add($($method))
$code.Add("} #close Get method`n")

$setFun = Get-DSCResourceFunction -Path $resource.path -Name Set-TargetResource
$code.Add("[void] Set() {")

$method = $setFun.Body
foreach ($prop in $resource.properties) {
	$method = Convert-VariableReference -VariableName $prop.name -CodeBlock $method
}
$code.Add($($method))
$code.Add("} #close Set method`n")

$testFun = Get-DSCResourceFunction -Path $resource.path -Name Test-TargetResource
$code.Add("[Bool] Test() {")
$method = $testFun.Body
foreach ($prop in $resource.properties) {
	$method = Convert-VariableReference -VariableName $prop.name -CodeBlock $method
}
$code.Add($($method))
$code.Add("} #close Test method`n")

$code.Add("} #close class")

<# #get external files and functions
get-functionname -Path $resource.path |
Where-Object { $_ -notmatch "[(Get)|(Set)|(Test)]-TargetResource" } | ForEach-Object {
    #save each function to a file
    $code.Add( $(Get-DSCHelperFunction -Path $resource.path -Name $_))
} #>

#insert mof
$code.add("`n<#")
$code.add("original schema.mof")
Get-Content $mofpath | ForEach-Object { $code.add($_) }
$code.add("#>")

$code


<#
[ClassVersion("1.0.0.0"), FriendlyName("xHotfix")]
class MSFT_xWindowsUpdate : OMI_BaseResource
{
    // We can have multiple versions of an update for a single ID, the indentifier is in the file,
    // Therefore the file path should be the key
    [key, Description("Specifies the path that contains the msu file for the hotfix installation.")] String Path;
    [required, Description("Specifies the Hotfix ID.")] String Id;
    [Write, Description("Specifies the location of the log that contains information from the installation.")] String Log;
    [Write, Description("Specifies whether the hotfix needs to be installed or uninstalled."), ValueMap{"Present","Absent"}, Values{"Present","Absent"}] String Ensure;
    [write, Description("Specifies the credential to use to authenticate to a UNC share if the path is on a UNC share."),EmbeddedInstance("MSFT_Credential")] string Credential;
};

#>


