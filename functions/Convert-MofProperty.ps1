#convert schema.mof properties to a class

Function Convert-SchemaMofProperty {
    [CmdletBinding()]
    [OutputType([String[]])]
    Param(
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            HelpMessage = 'Specify the path to the Schema.mof file.'
        )]
        [ValidateScript({ Test-Path $_ })]
        [ValidateNotNullOrEmpty()]
        [String]$Path
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
        [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::Initialize()
    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Processing $Path "
        $definition = [system.collections.generic.list[String]]::new()
        $mofSchemas = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ReadCimSchemaMof($Path)
        #There may be multiple schemas so select the correct one.
        $mofSchema = $mofSchemas.where({ $_.cimClassName -eq $resource.ResourceType })
        $ClassName = $mofSchema.cimClassName
        $props = $mofSchema.CimClassProperties | Sort-Object -Property Qualifiers

        foreach ($p in $props) {
            Switch ($p.Qualifiers.name) {
                'key' { $definition.add('[DscProperty(Key)]') ; Break }
                'required' { $definition.add('[DscProperty(Mandatory)]'); break }
                'read' { $definition.add('[DscProperty(NotConfigurable)]') }
                'write' { $definition.add('[DscProperty()]') }
            }
            if ($p.Qualifiers.name -contains 'Description') {
                $definition.Add("# $($p.Qualifiers.where({$_.name -eq 'description'}).value)")
            }
            if ($p.ReferenceClassName) {
                Switch ($p.ReferenceClassName) {
                    'MSFT_Credential' { $PropType = 'PSCredential' }
                    'StringArray' { $PropType = 'String[]' }
                    default { $PropType = $p.ReferenceClassName }
                }
            }
            elseif ( $p.qualifiers.name -match 'valuemap'  ) {
                #if value map exists then an enum will be defined and the property type
                #should match the enum
                $PropType = $p.Name
            }
            else {
                Switch ($p.cimType) {
                    'StringArray' { $PropType = 'String[]' }
                    Default { $PropType = $p.CimType }
                }
            }
            $definition.add("[$PropType]`$$($p.name)`n")
        }

        #return a hashtable
        @{ClassName = $ClassName; Properties = $definition }

    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"
    } #end

} #close Convert-SchemaMofProperty
