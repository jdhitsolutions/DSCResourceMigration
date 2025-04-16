---
external help file: DSCResourceMigration-help.xml
Module Name: DSCResourceMigration
online version: https://jdhitsolutions.com/yourls/c54e9a
schema: 2.0.0
---

# Convert-Mof

## SYNOPSIS

Convert a schema.mof

## SYNTAX

```yaml
Convert-Mof [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION

Convert a schema.mof to a structured object.

## EXAMPLES

### Example 1

```powershell
PS C:\> $MofPath = Get-SchemaMofPath -Name xhotfix -Module xWindowsUpdate
PS C:\> $mof = Convert-Mof $MofPath
PS C:\> $mof

Name                FriendlyName Properties
----                ------------ ----------
MSFT_xWindowsUpdate xHotfix      {@{DSCType=Key; PropertyType=String; PropertyN…
```

Warnings about failure to find a READ property are not unexpected.

## PARAMETERS

### -Path

The path to the schema MOF file to convert.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/yourls/newsletter

## RELATED LINKS

[Get-SchemaMofProperty](Get-SchemaMofProperty.md)

[Convert-SchemaMofProperty](Convert-SchemaMofProperty.md)

[Get-SchemaMofPath](Get-SchemaMofPath.md)
