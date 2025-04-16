---
external help file: DSCResourceMigration-help.xml
Module Name: DSCResourceMigration
online version: https://jdhitsolutions.com/yourls/d90d56
schema: 2.0.0
---

# Get-DSCResourceFunction

## SYNOPSIS

Export the Get/Set/Test script block from a DSC Resource function

## SYNTAX

```yaml
Get-DSCResourceFunction [-Path] <String> -Name <String[]> [<CommonParameters>]
```

## DESCRIPTION

Export the Get/Set/Test script block from a DSC Resource function

## EXAMPLES

### Example 1

This command is used internally by New-DSCClassDefinition.

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

Specify the .ps1 or .psm1 file with defined functions.

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

[Get-DSCHelperFunction](Get-DSCHelperFunction.md)
