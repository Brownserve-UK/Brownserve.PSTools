---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Invoke-ConvertToYaml

## SYNOPSIS

Wrapper cmdlet for ConvertTo-YAML

## SYNTAX

```text
Invoke-ConvertToYaml [-InputObject] <Object> [[-Parameters] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION

This is a wrapper cmdlet for calling `ConvertTo-YAML` to get around the issue of loading the powershell-yaml and PlatyPS modules at the same time (https://github.com/PowerShell/platyPS/issues/592). This cmdlet allows you to pass parameters through to ConvertTo-YAML via a hashtable.

## EXAMPLES

### Example 1: Convert with parameters

```powershell
$Params = @{KeepArray = $true}
$Data = @("hello, world!")
Invoke-ConvertToYaml $Data -Parameters $Params
```

Would convert the data in `$String` to YAML, retaining the array.

## PARAMETERS

### -InputObject

The object to be converted into YAML.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Parameters

Any parameters to pass through to ConvertTo-YAML

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Object

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
