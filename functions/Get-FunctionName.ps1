Function Get-FunctionName {
    [CmdletBinding()]
    [alias('gfn')]
    [OutputType("string", "PSFunctionName")]
    Param(
        [Parameter(
            Position = 0,
            Mandatory,
            ValueFromPipeline,
            HelpMessage = "Specify the .ps1 or .psm1 file with defined functions."
        )]
        [ValidateScript({
            If (Test-Path $_ ) {
                $True
                If ($_ -match "\.ps(m)?1$") {
                    $True
                }
                Else {
                    Throw "The path must be to a .ps1 or .psm1 file."
                    $False
                }
            }
            Else {
                Throw "Can't validate that $_ exists. Please verify and try again."
                $False
            }
        })]
        [alias("PSPath")]
        [String]$Path,
        [Parameter(HelpMessage = "List all detected function names.")]
        [Switch]$All,
        [Parameter(HelpMessage = "Write a rich object to the pipeline.")]
        [Switch]$Detailed
    )

    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
    } #begin
    Process {
        $Path = Convert-Path -Path $path
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Parsing $path for functions."
        $AST = Get-AST $path

        #parse out functions using the AST
        $functions = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)
        if ($functions.count -gt 0) {
            if ($All) {
                $out = $Functions.Name
            }
            Else {
                $out = $functions.Name
            }
            if ($Detailed) {
                foreach ($item in $($out | Sort-Object)) {
                    [PSCustomObject]@{
                        PSTypeName = "PSFunctionName"
                        Name       = $item
                        Path       = $Path
                    }
                }
            }
            else {
                $out
            }
        }
        else {
            Write-Warning "No PowerShell functions detected in $path."
        }
    } #process
    End {
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"
    } #end
} #close function
