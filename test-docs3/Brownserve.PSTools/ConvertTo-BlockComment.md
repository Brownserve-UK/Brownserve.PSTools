---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# ConvertTo-BlockComment

## SYNOPSIS
Converts a given text string into a block comment

## SYNTAX

```
ConvertTo-BlockComment [-InputObject] <String[]> [[-CommentCharacter] <String>] [<CommonParameters>]
```

## DESCRIPTION
Converts a given text string into a block comment by prepending a given character to the start of each string

## EXAMPLES

### Example 1
```
"My String" | ConvertTo-BlockComment
```

Would result in "# My String" being returned.

## PARAMETERS

### -CommentCharacter
The character to prepend to each string

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "#"
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -InputObject
The string(s) to be turned into a block comment

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]
### System.String
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

