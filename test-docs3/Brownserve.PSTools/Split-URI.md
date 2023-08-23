---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version: https://api.slack.com/messaging/composing/layouts
schema: 2.0.0
---

# Split-URI

## SYNOPSIS
Takes a given URI and splits it into its constituent parts.

## SYNTAX

```
Split-URI [-InputObject] <String[]> [-AsHashtable] [<CommonParameters>]
```

## DESCRIPTION
This will split a given URI into its relevant parts, protocol/domain/subdomain/hostname and the full URI.

## EXAMPLES

### Example 1: Split URL
```
'https://www.example.com/' | Split-URI

Protocol  : https
Domain    : com
Subdomain : www
Hostname  : example
URI       : https://www.example.com/
```

Splits the given URL into the parts listed above.

## PARAMETERS

### -AsHashtable
Returns a hashtable instead of a PS object

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

### -InputObject
The URI to be split

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
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
