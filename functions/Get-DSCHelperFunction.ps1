
#export the script block from a DSC Resource function
Function Get-DSCHelperFunction {
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Specify the .ps1 or .psm1 file with defined functions.")]
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
        [string]$Path,
        [Parameter(Mandatory, HelpMessage = "Specify a function by name")]
        [string[]]$Name
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"

    } #begin

    Process {
        $path = Convert-Path -Path $path
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Getting Function $function from $Path "
        $AST = Get-AST $path

        $functions = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] -AND $args[0].Name -eq $Name }, $true)
        if ($functions.count -gt 0) {
            Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Processing $($functions.name)"
            $functions.extent.text
        }
        else {
            Write-Warning "No matching functions found in $path"
        }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"

    } #end

} #close