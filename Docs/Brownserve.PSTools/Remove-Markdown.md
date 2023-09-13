---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Remove-Markdown

## SYNOPSIS

This cmdlet removes markdown from a string.

## SYNTAX

```text
Remove-Markdown [-String] <String[]> [<CommonParameters>]
```

## DESCRIPTION

This cmdlet removes markdown from a string.

## EXAMPLES

### Example 1

```powershell
$Markdown = '# Title'
Remove-Markdown -String $Markdown
```

This would simply return the string 'Title'

## PARAMETERS

### -String

The string to remove markdown from.

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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
