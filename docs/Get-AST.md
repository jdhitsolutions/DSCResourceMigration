---
external help file: DSCResourceMigration-help.xml
Module Name: DSCResourceMigration
online version: https://jdhitsolutions.com/yourls/18dd12
schema: 2.0.0
---

# Get-AST

## SYNOPSIS

Get the AST of PowerShell file

## SYNTAX

```yaml
Get-AST [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION

This command will return the AST of a PowerShell file. It is useful for debugging and understanding the structure of PowerShell scripts.

## EXAMPLES

### Example 1

```powershell
PS C:\> $resource = Get-DscResource -Name xHotfix -Module xWindowsUpdate
PS C:\> $ast = Get-AST -Path $resource.Path
```

## PARAMETERS

### -Path

The path to the PowerShell script file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
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
