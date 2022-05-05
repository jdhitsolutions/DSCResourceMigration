#this should run in windows PowerShell for now

#Second development pass

#convert a single resource

[cmdletbinding()]
Param($Name = "xHotFix")

Import-Module $psscriptroot\DSCResourceMigration.psd1 -Force

$code = [System.Collections.Generic.list[string]]::New()
Write-Verbose "Getting DSC Resource $name"
$resource = Get-DscResource -Name $name
$parent = Split-Path $resource.Path
$mofPath = Join-Path $parent -child "$($resource.ResourceType).schema.mof"

#friendly name vs offical class name
$newversion = [version]::New($resource.Version.major + 1, 0, 0, 0)

$Mof = Convert-Mof $mofpath

Write-Verbose "Getting localized data"
$ast = Get-AST -path $resource.path
$ds = $ast.findall({ $args[0] -is [System.Management.Automation.Language.DataStatementAst] }, $true)
$code.Add($ds.extent.text)

#TODO: parse other module code

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

<# #get key property
Write-Verbose "Getting key property from $mofPath"
$key = Get-SchemaMofProperty -Path $mofPath -type key -Verbose
Write-Verbose "Key property is $($key.propertyname)"


#need to get default parameter values from script
foreach ($prop in $resource.properties) {
    Write-Verbose "Processing property $($prop.name)"
    if ($prop.name -eq $key.propertyname) {
        $dscProperty = "Key"
    }
    elseif ($prop.IsMandatory) {
        $dscProperty = "Mandatory"
    }
    else {
        $dscProperty = $null
    }
    $code.Add("[DscProperty($dscProperty)]")

    if ($prop.Values.count -gt 1) {
        $ptype = "[$($prop.Name)]"
    }
    else {
        $ptype = $prop.PropertyType
    }
    $code.Add("  $ptype`$$($prop.Name)`n")

} #foreach #>

#parse module file to get method code
#TODO :Insert RETURN keyword
#TODOI: Need to change non property variables to gloval scope

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

#get external files and functions
get-functionname -Path $resource.path |
Where-Object { $_ -notmatch "[(Get)|(Set)|(Test)]-TargetResource" } | ForEach-Object {
    #save each function to a file
    $code.Add( $(Get-DSCHelperFunction -Path $resource.path -Name $_))
}

#insert mof
$code.add("<#")
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


