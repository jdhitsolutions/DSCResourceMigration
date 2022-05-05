Function Convert-VariableReference {
    #convert variable references to $this.<name> to support class methods
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the variable name without the $ like Path")]
        [ValidateNotNullOrEmpty()]
        [string]$VariableName,
        [Parameter(Mandatory, HelpMessage = "What is the code block to be updated.")]
        [ValidateNotNullOrEmpty()]
        [string[]]$CodeBlock
    )
    Write-Verbose "Updating references of `$$VariableName"
    $rx = "\`$(?=({)?$VariableName)"

    Write-Verbose "Using pattern $rx"
    $codeblock -replace $rx, '$this.'
}