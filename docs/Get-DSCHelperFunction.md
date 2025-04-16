---
external help file: DSCResourceMigration-help.xml
Module Name: DSCResourceMigration
online version: https://jdhitsolutions.com/yourls/9827da
schema: 2.0.0
---

# Get-DSCHelperFunction

## SYNOPSIS

Export the script block from a DSC Resource function.

## SYNTAX

```yaml
Get-DSCHelperFunction [-Path] <String> -Name <String[]> [<CommonParameters>]
```

## DESCRIPTION

Export the script block from a DSC Resource function.

## EXAMPLES

### Example 1

```powershell
PS C:\> $resource = Get-DscResource -Name xHotfix -Module xWindowsUpdate
PS C:\> Get-DSCHelperFunction -Path $resource.path -Name Get-TargetResource
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    Param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [parameter(Mandatory = $true)]
        [System.String]
        $Id
    )
    Set-StrictMode -Version latest

    $uri, $kbId = Test-StandardArguments -Path $Path -Id $Id

    Write-Verbose $($LocalizedData.GettingHotfixMessage -f ${Id})

    $hotfix = Get-HotFix -Id "KB$kbId"

    $returnValue = @{
        Path = ''
        Id = $hotfix.HotFixId
        Log = ''
    }

    $returnValue

}
```

## PARAMETERS

### -Name

Specify a function by name.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

.psm1 file with defined functions.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/yourls/newsletter

## RELATED LINKS

[Get-FunctionName](Get-FunctionName.md)

[Get-DSCResourceFunction](Get-DSCResourceFunction.md)
