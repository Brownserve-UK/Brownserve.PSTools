---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# ConvertTo-SortedHashtable

## SYNOPSIS
Converts a given hashtable to an alphabetically sorted hashtable

## SYNTAX

```
ConvertTo-SortedHashtable [-InputObject] <Hashtable[]> [<CommonParameters>]
```

## DESCRIPTION
Converts a given hashtable to an alphabetically sorted hashtable

## EXAMPLES

### Example 1
```
@{'a' = 1;'c' = 3;b = 2} | ConvertTo-SortedHashtable

Name                           Value
----                           -----
a                              1
b                              2
c                              3
```

Converts to a sorted hashtable

## PARAMETERS

### -InputObject
The hashtable(s) to be sorted

```yaml
Type: Hashtable[]
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

### System.Collections.Hashtable[]
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
