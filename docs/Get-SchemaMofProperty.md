---
external help file: DSCResourceMigration-help.xml
Module Name: DSCResourceMigration
online version: https://jdhitsolutions.com/yourls/ad3437
schema: 2.0.0
---

# Get-SchemaMofProperty

## SYNOPSIS

Get MOF schema keys

## SYNTAX

```yaml
Get-SchemaMofProperty [-Path] <String> [-Type <String>]  [<CommonParameters>]
```

## DESCRIPTION

This command will process a schema MOF file and return information about different key types. This is used internally in Convert-Mof

## EXAMPLES

### Example 1

```powershell
PS C:\> $MofPath = Get-SchemaMofPath -Name xhotfix -Module xWindowsUpdate
PS C:\> Get-SchemaMofProperty -Path $MofPath -Type write

DSCType      : write
PropertyType : String
PropertyName : Log
Description  : Specifies the location of the log that contains information from the installation.
ValueMap     : {}

DSCType      : write
PropertyType : String
PropertyName : Ensure
Description  : Specifies whether the hotfix needs to be installed or uninstalled.
ValueMap     : {Present, Absent}

DSCType      : write
PropertyType : string
PropertyName : Credential
Description  : Specifies the credential to use to authenticate to a UNC share if the path is on a UNC share.
ValueMap     : {}
```

## PARAMETERS

### -Path

Full path to the schema mof file

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

### -Type

Specify the MOF property type

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Key, Required, Read, Write

Required: False
Position: Named
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

[Convert-Mof](Convert-Mof.md)
