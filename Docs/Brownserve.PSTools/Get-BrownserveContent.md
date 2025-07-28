---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Get-BrownserveContent

## SYNOPSIS

Wrapper for Get-Content that returns the content in a format that is easier to work with.

## SYNTAX

```text
Get-BrownserveContent [-Path] <String[]> [<CommonParameters>]
```

## DESCRIPTION

This cmdlet ensures that any content is returned in a format that is easy to work with in pipelines.
It stores the content as a string array so it can be easily iterated over while stripping any line breaks.
It also detects the line endings of the file and stores that information in the returned object so the file can
be saved with the same line endings.

## EXAMPLES

### Example 1

```powershell
$myContent = Get-BrownserveContent -Path C:\myFile.txt
```

This would return the content of `myFile.txt` and store it in a `[BrownserveContent]` object that can be ingested by other cmdlets (such as `Set-BrownserveContent`)

## PARAMETERS

### -Path

The path to the file to get content from

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: PSPath

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
