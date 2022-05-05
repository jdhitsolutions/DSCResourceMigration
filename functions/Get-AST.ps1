Function Get-AST {
    [cmdletbinding()]
    Param([string]$Path)

    New-Variable astTokens -Force -WhatIf:$false
    New-Variable astErr -Force -WhatIf:$false
    Write-Verbose "Parsing file $path for AST tokens"
    $AST = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$astTokens, [ref]$astErr)
    $AST
}

