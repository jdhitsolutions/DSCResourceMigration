#create enums from the value map in schema.mof files

Function New-DSCEnum {
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
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #nd
}