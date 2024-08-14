Function Get-SchemaMofProperty {
    [CmdletBinding()]
    Param(
        [parameter(Position = 0, Mandatory, HelpMessage = "Full path to the schema mof file")]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("\.mof$")]
        [String]$Path,
        [Parameter(HelpMessage = "Specify the MOF property type")]
        [ValidateSet("Key", "Required", "Read", "Write")]
        [String]$Type = "Key"
    )
    Write-Verbose "Starting $($MyInvocation.MyCommand)"
    Write-Verbose "Getting the schema mof $type property from $Path"
    [regex]$rxKey = "\[$Type.*\s(?<prop>(\w+)(?=;))"
    Write-Verbose "Using pattern $rxKey"
    $selected = Select-String -Pattern $rxKey -Path $Path
    if ($selected) {
        foreach ($item in $selected) {
            Write-Verbose "Parsing $($item.line)"
            [PSCustomObject]@{
                DSCType      = $Type
                PropertyType = [System.Text.RegularExpressions.Regex]::Match($item.line, "(?<=\]\s)\w+(?=\s)").value
                PropertyName = [System.Text.RegularExpressions.Regex]::Match($item.line, "\w+(?=;$)").value
                Description  = [System.Text.RegularExpressions.Regex]::Match($item.line, '(?<=Description\(.).*?(?=.\))').value
                ValueMap     = [System.Text.RegularExpressions.Regex]::Match($item.line, '(?<=Values{).*?(?=})').value.replace('"', '').split(",")
            }
        }
    } #if selected found
    else {
        Write-Warning "Failed to find a $type property in $Path. This may be by design."
    }
} #close function

<#
   Write-Verbose "Getting the schema mof $type property from $Path"
    [regex]$rxKey = "(?<=\[)$Type.*\s(?<prop>(\w+)(?=;))"
    Write-Verbose "Using pattern $rxKey"
    $mofText = [System.Collections.Generic.List[System.String]]::new()
    Get-Content $Path | ForEach-Object {
        $mofText.Add($_.replace("//", "#"))
    }

    $line = $moftext.Find({ $args[0] -match $rxkey })
    $rxkey.match($line).groups["prop"].value
#>
