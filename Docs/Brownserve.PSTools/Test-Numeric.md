---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Test-Numeric

## SYNOPSIS

Tests if a given object is numeric.

## SYNTAX

```text
Test-Numeric [-InputObject] <PSObject> [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will test if a given object is numeric.

## EXAMPLES

### Example 1

```powershell
Test-Numeric -InputObject 5
```

This would return true as 5 is a number.

## PARAMETERS

### -InputObject

The object to test

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
