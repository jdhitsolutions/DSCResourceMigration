---
external help file: DSCResourceMigration-help.xml
Module Name: DSCResourceMigration
online version: https://jdhitsolutions.com/yourls/f49bf5
schema: 2.0.0
---

# Convert-SchemaMofProperty

## SYNOPSIS

Convert schema.mof properties to a class

## SYNTAX

```yaml
Convert-SchemaMofProperty [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION

Convert schema.mof properties to a class

## EXAMPLES

### Example 1

```powershell
PS C:\> $MofPath = Get-SchemaMofPath -Name xhotfix -Module xWindowsUpdate
PS C:\> Convert-SchemaMofProperty -Path $mofPath

Name                           Value
----                           -----
ClassName                      MSFT_xWindowsUpdate
Properties                     {[DscProperty(Key)], # Specifies the path that contains the msu file for the hotfix ins
```

## PARAMETERS

### -Path

Specify the path to the Schema.mof file.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.String[]

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/yourls/newsletter

## RELATED LINKS

[Convert-Mof](Convert-Mof.md)

[Get-SchemaMofProperty](Get-SchemaMofProperty.md)
