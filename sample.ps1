#this should run in windows PowerShell for now
[cmdletbinding()]
Param($Name = "xHotFix")

# [Microsoft.PowerShell.DesiredStateConfiguration.DscResourcePropertyInfo]::new()

#create destination path and folder structure

$code = [System.Collections.Generic.list[string]]::New()

Import-Module $psscriptroot\DSCResourceMigration.psd1 -Force

#friendly name vs offical class name
$newversion = [version]::New($resource.Version.major + 1, 0, 0, 0)

Write-Verbose "Getting DSC Resource $name"
$resource = Get-DscResource -Name $name
$parent = Split-Path $resource.Path
$mofPath = Join-Path $parent -child "$($resource.ResourceType).schema.mof"

Write-Verbose "Getting localized data"
$ast = Get-AST -path $resource.path
$ds = $ast.findall({ $args[0] -is [System.Management.Automation.Language.DataStatementAst] }, $true)
$code.Add($ds.extent.text)

# need to identify enums
$resource.properties.where({ $_.values }).foreach({
        $code.Add("enum $($_.name) {")
        Foreach ($v in $_.values) {
            $code.Add("  $($v)")
        }
        $code.add("}`n")
    })

#get key property
Write-Verbose "Getting key property from $mofPath"
$key = Get-SchemaMofProperty -Path $mofPath -type key -Verbose
Write-Verbose "Key property is $($key.propertyname)"
$code.Add("[DSCResource()]")
$code.add("Class $name {")

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

} #foreach

#parse module file to get method code
#TODO: variables in methods need to changed to $this.<name>
$getFun = Get-DSCResourceFunction -Path $resource.path -Name Get-TargetResource
$code.Add("[$Name] Get() {")
#todo :Insert RETURN keyword
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

#create module

#create manifest

return $code


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


