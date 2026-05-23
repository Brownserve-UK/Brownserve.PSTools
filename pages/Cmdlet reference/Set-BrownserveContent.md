---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Set-BrownserveContent

## SYNOPSIS

Writes the contents of a file to disk.

## SYNTAX

```text
Set-BrownserveContent [-Path] <String[]> [[-Content] <String[]>] [[-LineEnding] <BrownserveLineEnding>]
 [[-InsertFinalNewline] <Boolean>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet is effectively just a wrapper around the Set-Content cmdlet.
It allows us to maintain a complete
pipeline for working with file content.

## EXAMPLES

### Example 1

```powershell
$myFile = Get-BrownserveContent -Path C:\MyFile.txt
$myFile.Content += "Hello, world!"
$myFile | Set-BrownserveContent
```

This would append "Hello, world!" to the end of `MyFile.txt`

## PARAMETERS

### -Content

The content to write to the file, should be an array of strings without any new line characters

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Value

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -InsertFinalNewline

Whether or not to insert a final newline if one is not present

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path

The path to the file(s) to write

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: PSPath

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
