---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Get-VaultSecret

## SYNOPSIS
Returns a secret from a given vault path

## SYNTAX

```
Get-VaultSecret [-SecretPath] <String> [<CommonParameters>]
```

## DESCRIPTION
Returns a secret from a given vault path

## EXAMPLES

### EXAMPLE 1
```
Get-VaultSecret -SecretPath credentials/live/github/token
```

This would return the value of \`credentials/live/github/token\`

## PARAMETERS

### -SecretPath
The path to the secret

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path

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
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
