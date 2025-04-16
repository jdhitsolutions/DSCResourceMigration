---
external help file: DSCResourceMigration-help.xml
Module Name: DSCResourceMigration
online version: https://jdhitsolutions.com/yourls/343c26
schema: 2.0.0
---

# New-DSCClassDefinition

## SYNOPSIS

Convert a DSC resource to a class definition

## SYNTAX

```yaml
New-DSCClassDefinition [-Name] <String> [-Module] <Object> [<CommonParameters>]
```

## DESCRIPTION

Convert a DSC resource to a class-based definition. The output is the new definition. You can pipe output to a file or the clipboard.

## EXAMPLES

### Example 1

```powershell
PS C:\> New-DSCClassDefinition -Name xhotfix -Module xWindowsUpdate | Set-Clipboard
```

Create a class definition for the xHotfix resource and copy the output to the clipboard.

## PARAMETERS

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
