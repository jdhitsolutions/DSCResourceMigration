---
external help file: DSCResourceMigration-help.xml
Module Name: DSCResourceMigration
online version: https://jdhitsolutions.com/yourls/c8c87f
schema: 2.0.0
---

# Get-SchemaMofPath

## SYNOPSIS

Get the schema MOF path

## SYNTAX

```yaml
Get-SchemaMofPath [-Name] <String> [-Module] <Object> [-Content]  [<CommonParameters>]
```

## DESCRIPTION

Use this command to retrieve the the schema MOF path for a DSC resource. The path is the location of the schema.mof file for the specified DSC resource.

## EXAMPLES

### Example 1

```powershell
PS C:\> Get-SchemaMofPath -Name xhotfix -Module xWindowsUpdate
C:\Program Files\WindowsPowerShell\Modules\xWindowsUpdate\2.8.0.0\DscResources\MSFT_xWindowsUpdate\MSFT_xWindowsUpdate.schema.mof
```

### Example 2

```powershell
PS C:\> get-SchemaMofPath -Name xhotfix -Module xWindowsUpdate -Content
[ClassVersion("1.0.0.0"), FriendlyName("xHotfix")]
class MSFT_xWindowsUpdate : OMI_BaseResource
{
    // We can have multiple versions of an update for a single ID, the indentifier is in the file,
    // Therefore the file path should be the key
    [key, Description("Specifies the path that contains the msu file for the hotfix installation.")] String Path;
    [required, Description("Specifies the Hotfix ID.")] String Id;
    [Write, Description("Specifies the location of the log that contains information from the installation.")] String Log;
    [Write, Description("Specifies whether the hotfix needs to be installed or uninstalled."), ValueMap{"Present","Absent"}, Values{"Present","Absent"}] String Ensure;
    [write, Description("Specifies the credential to use to authenticate to a UNC share if the path is on a UNC share."),EmbeddedInstance("MSFT_Credential")] string Credential;
};
```

## PARAMETERS

### -Content

Get the contents of the file instead of only the path.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Module

Enter the DSC module name for the resource

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name

Enter the DSC Resource name

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

### System.Object

## OUTPUTS

### System.Object

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/yourls/newsletter

## RELATED LINKS

[Get-SchemaMofProperty](Get-SchemaMofProperty.md)

[Convert-Mof](Convert-Mof.md)
