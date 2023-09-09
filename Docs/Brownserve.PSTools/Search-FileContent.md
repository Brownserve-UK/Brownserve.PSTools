---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Search-FileContent

## SYNOPSIS
Searches a file for a given set of regex and returns any text between them.

## SYNTAX

```
Search-FileContent [-FilePath] <String> [-StartStringPattern] <String> [[-StopStringPattern] <String>]
 [-AsString] [<CommonParameters>]
```

## DESCRIPTION
Searches a file for a given set of regex and returns any text between them.

## EXAMPLES

### Example 1
```powershell
Search-FileContent -FilePath 'C:\MyFile.txt' -StartStringPattern '### Start Section' -StopStringPattern '### Stop Section'
```

Would return any text found between the `### Start Section` and `### Stop Section` strings

## PARAMETERS

### -AsString
Returns the text as a string instead of an array

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

### -FilePath
The path to the file to search for content

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartStringPattern
The first line to look for

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StopStringPattern
The last line to look for, if not provided the end of the file will be used

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
