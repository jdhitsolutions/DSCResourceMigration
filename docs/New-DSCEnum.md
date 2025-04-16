---
external help file: DSCResourceMigration-help.xml
Module Name: DSCResourceMigration
online version: https://jdhitsolutions.com/yourls/0242f6
schema: 2.0.0
---

# New-DSCEnum

## SYNOPSIS

Create DSC enums

## SYNTAX

```yaml
New-DSCEnum [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION

Create enums from the value map in schema.mof files

## EXAMPLES

### Example 1

```powershell
PS C:\> $MofPath = Get-SchemaMofPath -Name xhotfix -Module xWindowsUpdate
PS C:\> New-DSCEnum $MofPath`
enum Ensure {
Present
Absent
}
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
