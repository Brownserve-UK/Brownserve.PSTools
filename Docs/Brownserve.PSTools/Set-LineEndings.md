---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Set-LineEndings

## SYNOPSIS
Sets the line endings of a file to either CRLF or LF

## SYNTAX

```
Set-LineEndings [-Path] <String[]> [[-LineEnding] <String>] [<CommonParameters>]
```

## DESCRIPTION
Due to the way PowerShell handles line endings when creating/updating files it can be difficult to ensure that the line endings are correct. This function will set the line endings of a file to either CRLF or LF.

## EXAMPLES

### Example 1: Set the line endings of a file to CRLF
```
PS C:\> Set-LineEndings -Path C:\Temp\test.txt -LineEnding CRLF
```

This command will set the line endings of the file C:\Temp\test.txt to CRLF

### Example 2: Set the line endings of a file to LF
```
PS C:\> Set-LineEndings -Path C:\Temp\test.txt -LineEnding LF
```

This command will set the line endings of the file C:\Temp\test.txt to LF

## PARAMETERS

### -LineEnding
The line ending to set the file to. Valid values are CRLF and LF

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: CRLF, LF

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Path
The path to the file to set the line endings of

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
