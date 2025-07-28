---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Assert-Path

## SYNOPSIS

Ensures a given path exists.

## SYNTAX

```text
Assert-Path [-Path] <String[]> [-Inverse] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will check for the presence of a given path and raise an exception if it cannot be found.
Inversely if you pass the '-Inverse' an exception will be raised if the path DOES exist.

## EXAMPLES

### Example 1

```powershell
PS C:\> Assert-Path -Path C:\MyPath
```

Will test to see if the path exists, if not then an exception will be raised.

## PARAMETERS

### -Inverse

If specified will raise an exception if the path exists

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

The path to check

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
