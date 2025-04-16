---
external help file: DSCResourceMigration-help.xml
Module Name: DSCResourceMigration
online version: https://jdhitsolutions.com/yourls/7ef658
schema: 2.0.0
---

# Get-FunctionName

## SYNOPSIS

Get function names

## SYNTAX

```yaml
Get-FunctionName [-Path] <String> [-All] [-Detailed] [<CommonParameters>]
```

## DESCRIPTION

This command uses the AST to retrieve function names from a PowerShell script file.

## EXAMPLES

### Example 1

```powershell
PS C:\> $resource = Get-DscResource -Name xHotfix -Module xWindowsUpdate
PS C:\> Get-FunctionName $resource.path
Get-TargetResource
Trace-Message
New-InvalidArgumentException
Set-TargetResource
Test-TargetResource
Test-StandardArguments
Test-WindowsUpdatePath
```

## PARAMETERS

### -All

List all detected function names.

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

### -Detailed

Write a rich detailed object to the pipeline.

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

### -Path

Specify the .ps1 or .psm1 file with defined functions.

```yaml
Type: String
Parameter Sets: (All)
Aliases: PSPath

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

### string

### PSFunctionName

## NOTES

Learn more about PowerShell: http://jdhitsolutions.com/yourls/newsletter

## RELATED LINKS

[Get-AST](Get-AST.md)
