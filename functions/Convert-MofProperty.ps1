#convert schema.mof properties to a class

Function Convert-SchemaMofProperty {
    [cmdletbinding()]
    [outputtype([String[]])]
    Param(
        [Parameter(ValueFromPipeline,Mandatory,HelpMessage = "Specify the path to the Schema.mof file.")]
        [ValidateScript({Test-Path $_})]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
        [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::Initialize()
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Processing $Path "
        $definition = [system.collections.generic.list[string]]::new()
        $mofSchemas = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ReadCimSchemaMof($mofPath)
        #There may be multiple schemas so select the correct one.
        $mofSchema = $mofSchemas.where({$_.cimclassname -eq $resource.ResourceType})
        $classname = $mofSchema.cimclassname
        $props = $mofSchema.CimClassProperties | Sort-Object -Property Qualifiers

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

        #return a hashtable
        @{ClassName = $classname;Properties=$definition}

    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end

} #close Convert-SchemaMofProperty