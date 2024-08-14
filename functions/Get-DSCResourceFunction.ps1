
#export the Get/Set/Test script block from a DSC Resource function
Function Get-DSCResourceFunction {
    [CmdletBinding()]
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
        [String]$Path,
        [Parameter(Mandatory, HelpMessage = "Specify a function by name")]
        [string[]]$Name
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeOfDay) BEGIN  ] Starting $($MyInvocation.MyCommand)"
        $body = [System.Collections.Generic.list[String]]::new()
    } #begin

    Process {
        $path = Convert-Path -Path $path
        Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Getting Function $function from $Path "
        $AST = Get-AST $path

        $functions = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] -AND $args[0].Name -eq $Name }, $true)
        if ($functions.count -gt 0) {
            Write-Verbose "[$((Get-Date).TimeOfDay) PROCESS] Processing $($functions.name)"
            ($functions.body.BeginBlock.statements.extent.text).foreach({ $body.Add("$_`n") })
            ($functions.body.ProcessBlock.statements.extent.text).foreach({ $body.Add("$_`n") })
            ($functions.body.EndBlock.statements.extent.text).foreach({ $body.Add("$_`n") })
            #capturing parameters for possible future use
            [PSCustomObject]@{
                Parameters = ($functions[0].body.ParamBlock.parameters | ForEach-Object { "[$($_.statictype)]$($($_.name))" }) -join ','
                Body       = $body
            }

        }
        else {
            Write-Warning "No matching functions found in $path"
        }
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeOfDay) END    ] Ending $($MyInvocation.MyCommand)"
    } #end

} #close
