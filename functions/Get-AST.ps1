Function Get-AST {
    [CmdletBinding()]
    Param(
        [Parameter(
            Position = 0,
            Mandatory,
            HelpMessage = "Enter the path to the file to be parsed."
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [String]$Path
        )

    New-Variable astTokens -Force -WhatIf:$false
    New-Variable astErr -Force -WhatIf:$false
    Write-Verbose "Parsing file $path for AST tokens"
    $AST = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$astTokens, [ref]$astErr)
    $AST
}

