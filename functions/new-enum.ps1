#create enums from the value map in schema.mof files

Function New-DSCEnum {
    [OutputType([String[]])]
    Param(
        [Parameter(ValueFromPipeline,Mandatory,HelpMessage = "Specify the path to the Schema.mof file.")]
        [ValidateScript({Test-Path $_})]
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
        $maps = ($mofSchemas.cimclassproperties).where({ $_.qualifiers.name -eq 'ValueMap'})
        foreach ($item in $maps) {
            $definition.Add("enum $($item.name) {")
            $maps.Qualifiers.where({$_.name -eq "Values"}).Value.Foreach({$definition.Add($_)})
            $definition.Add("}`n")
        }
        $definition
    } #process
    End {
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"
    } #nd
}
