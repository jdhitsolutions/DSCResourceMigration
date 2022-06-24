#this is development script
return

if (Get-Module PSDesiredStateConfiguration) {
    Remove-Module PSDesiredStateConfiguration
}
Import-Module PSDesiredStateConfiguration -RequiredVersion 2.0.5

$resource = Get-DscResource -Name xhotfix -Module xwindowsUpdate
$parent = Split-Path $resource.Path
$mofPath = Join-Path $parent -child "$($resource.ResourceType).schema.mof"

[Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::Initialize()
# This requires v2.0.5 of PSDesiredStateConfiguration
$mofSchemas = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ReadCimSchemaMof($mofPath)

#There may be multiple schemas so select the correct one. But how?
$mofSchema = $mofSchemas.where({$_.cimclassname -eq $resource.ResourceType})
$classname = $mofSchema.cimclassname
$props = $mofSchema.CimClassProperties | Sort-Object -Property Qualifiers
<#

Name               : ResourceId
CimType            : String
Flags              : Property, Required, NullValue
Qualifiers         : {Required}
ReferenceClassName :

Name               : SourceInfo
CimType            : String
Flags              : Property, NullValue
Qualifiers         : {Write}
ReferenceClassName :

Name               : DependsOn
CimType            : StringArray
Flags              : Property, NullValue
Qualifiers         : {Write}
ReferenceClassName :

Name               : ModuleName
CimType            : String
Flags              : Property, Required, NullValue
Qualifiers         : {Required}
ReferenceClassName :

Name               : ModuleVersion
CimType            : String
Flags              : Property, Required, NullValue
Qualifiers         : {Required}
ReferenceClassName :

Name               : ConfigurationName
CimType            : String
Flags              : Property, NullValue
Qualifiers         : {Write}
ReferenceClassName :

Name               : PsDscRunAsCredential
CimType            : Instance
Flags              : Property, NullValue
Qualifiers         : {Write, EmbeddedInstance}
ReferenceClassName : MSFT_Credential

Name               : Path
CimType            : String
Flags              : Property, Key, NullValue
Qualifiers         : {Key, Description}
ReferenceClassName :

Name               : Id
CimType            : String
Flags              : Property, Required, NullValue
Qualifiers         : {Required, Description}
ReferenceClassName :

Name               : Log
CimType            : String
Flags              : Property, NullValue
Qualifiers         : {Write, Description}
ReferenceClassName :

Name               : Ensure
CimType            : String
Flags              : Property, NullValue
Qualifiers         : {Write, Description, ValueMap, Values}
ReferenceClassName :

Name               : Credential
CimType            : Instance
Flags              : Property, NullValue
Qualifiers         : {Write, Description, EmbeddedInstance}
ReferenceClassName : MSFT_Credential

#>

$definition = [system.collections.generic.list[string]]::new()
$definition.Add("[DSCResource()]")
$definition.Add("Class $classname {")
foreach ($p in $props) {
    Switch ($p.Qualifiers.name) {
        "key" { $definition.add("[DscProperty(Key)]") ; Break }
        "required" { $definition.add("[DscProperty(Mandatory)]"); break }
        "read" { $definition.add("[DscProperty(NotConfigurable)]") }
        "write" { $definition.add("[DscProperty()]") }
    }
    if ($p.Qualifiers.name -contains 'Description') {
        $definition.Add("# $($p.Qualifiers.where({$_.name -eq 'description'}).value)")
    }
    if ($p.ReferenceClassName) {
        Switch ($p.ReferenceClassName) {
            "MSFT_Credential" { $proptype = "PSCredential" }
            "StringArray" { $propType = "String[]" }
            default { $propType = $p.ReferenceClassName }
        }
    }
    else {
        Switch ($p.cimType) {
         "StringArray" { $propType = "String[]"}
         Default { $propType = $p.CimType}
        }

    }
    $definition.add("[$propType]`$$($p.name)`n")
}
#add methods
$definition.add("[$classname] Get() { }")
$definition.add("[void] Set() { }")
$definition.add("[bool] Test() { }")

$definition.Add("} #end class definition")