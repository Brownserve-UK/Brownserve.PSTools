---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Format-BrownserveContent

## SYNOPSIS

Formats a given string to be compatible with the various *-BrownserveContent cmdlets.

## SYNTAX

```text
Format-BrownserveContent [-Content] <String> [[-InsertFinalNewline] <Boolean>]
 [[-LineEnding] <BrownserveLineEnding>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will take a string and format it so that it can be easily used with the *-BrownserveContent cmdlets.
This allows us to ensure files get written with the correct formatting and works around PowerShells inconsistent
line ending handling between Windows and Linux.

## EXAMPLES

### Example 1

```powershell
$myString = "Hello,world!`nI am a string with new lines`n!"
Format-BrownserveContent -Content $myString -LineEnding 'CRLF'
```

This would remove all line endings from the string and store the text in a special object.
Anytime the user calls `$myString.ToString()` the resulting object will use the `CRLF` endings

## PARAMETERS

### -Content

The content to format, should be a single string with each line separated by a newline character

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -InsertFinalNewline

If true inserts a final newline if one is not present

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -LineEnding

The line ending to use

```yaml
Type: BrownserveLineEnding
Parameter Sets: (All)
Aliases:
Accepted values: LF, CRLF, CR

Required: False
Position: 3
Default value: LF
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
