---
external help file: DSCResourceMigration-help.xml
Module Name: DSCResourceMigration
online version: https://jdhitsolutions.com/yourls/9d3cdc
schema: 2.0.0
---

# Convert-VariableReference

## SYNOPSIS

Convert variable references

## SYNTAX

```yaml
Convert-VariableReference [-VariableName] <String> -CodeBlock <String[]> [<CommonParameters>]
```

## DESCRIPTION

Convert variable references to $this.<name> to support class methods. This function is used internally by New-DSCClassDefinition, you shouldn't need to run it directly.

## EXAMPLES

### Example 1

```powershell
PS C:\> $resource = Get-DscResource -Name xHotFix -Module xWindowsUpdate
PS C:\> $setFun = Get-DSCResourceFunction -Path $resource.path -Name Set-TargetResource
PS C:\> $method = $setFun.Body
PS C:\> foreach ($prop in $resource.properties) { $method = Convert-VariableReference -VariableName $prop.name -CodeBlock $method}
PS C:\> $method
Set-StrictMode -Version latest

if (!$this.Log)
    {
        $this.Log = [IO.Path]::GetTempFileName()
        $this.Log += '.etl'

        Write-Verbose "$($LocalizedData.LogNotSpecified -f $this.{Log})"
    }

$uri, $kbId = Test-StandardArguments -Path $this.Path -Id $this.Id
...
```

## PARAMETERS

### -CodeBlock

What is the code block to be updated.

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

### -VariableName

Enter the variable name without the $ like Path

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
