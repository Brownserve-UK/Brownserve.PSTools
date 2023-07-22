---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Merge-Hashtable

## SYNOPSIS
Merges two hashtables together

## SYNTAX

```
Merge-Hashtable [-BaseObject] <Hashtable> [-InputObject] <Hashtable[]> [-Deep] [<CommonParameters>]
```

## DESCRIPTION
Merges two hashtables together.
If a key exists in both the `BaseObject` and `InputObject` then the value from `InputObject` will be used.
If `-Deep` is specified then when a value is an array or another hashtable then the cmdlet will attempt to merge them.

## EXAMPLES

### Example 1: Simple merge
```powershell
> $hash = @{ 
key1 = 'value1'
key2 = 'value2'
}

> $hash2 = @{
key1 = 'value1'
key2 = 'value3'
}

> Merge-Hashtable -BaseObject $hash -InputObject $hash2

Name                           Value
----                           -----
key2                           value3
key1                           value1
```

Performs a simple merge, as key2 exists in both hashtables its value is replaced by the value of the `InputObject` hashtable.

### Example 2: Deep merge
```powershell
> $hash1 = @{
key1 = 'value1'
arr1 = @('a','b','c')
nested_hash1 = @{ 'key2' = 'value2'}
}

> $hash2 = @{
key1 = 'value1'
arr1 = @('a','d','e')
nested_hash1 = @{'key2' = 'value3';'key3' = 'value4'}
}

> Merge-Hashtable -BaseObject $hash1 -InputObject $hash2 -Deep

Name                           Value
----                           -----
arr1                           {a, b, c, d…}
key1                           value1
nested_hash1                   {[key2, value3], [key3, value4]}
```

Performs a deep merge of the two hashtables.
The values of `arr1` are merged together and duplicates removed.
`key2` from `nested_hash1` has been overwritten as it exists in both, `key3` has been added.

## PARAMETERS

### -BaseObject
The base object to be used as part of the merge.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Deep
Whether or not to perform a deep merge.
This will inspect each value and if they are another object that can be merged (arrays/hashes) then they will be merged.

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

### -InputObject
The object that should be merged with the `BaseObject`

```yaml
Type: Hashtable[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
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

## RELATED LINKS
