---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Select-BrownserveContent

## SYNOPSIS

Selects text from a given file

## SYNTAX

### Default (Default)

```text
Select-BrownserveContent [[-After] <PSObject>] [[-Before] <PSObject>] [-FailIfNotFound]
 [<CommonParameters>]
```

### Path

```text
Select-BrownserveContent [-Path] <String[]> [[-After] <PSObject>] [[-Before] <PSObject>] [-FailIfNotFound]
 [<CommonParameters>]
```

### Content

```text
Select-BrownserveContent [[-After] <PSObject>] [[-Before] <PSObject>] [-FailIfNotFound]
 [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will select text from a given file.
You can specify a `After` and/or `Before` parameter to select text between two points
these can be either a line number or a string/regex.
You can pipe content from Get-BrownserveContent into this cmdlet.

## EXAMPLES

### Example 1

```powershell
Select-BrownserveContent -Path "C:\temp\test.txt" -After 5 -Before 10
```

This will return the content of the file `C:\temp\test.txt` from line 5 to 10

### Example 2

```powershell
Get-BrownserveContent -Path "C:\temp\test.txt" | Select-BrownserveContent -After 5 -Before 10
```

This will return the content of the file `C:\temp\test.txt` from line 5 to 10

### Example 3

```powershell
Get-BrownserveContent -Path "C:\temp\test.txt" | Select-BrownserveContent -After "##Start" -Before "##End"
```

This will return the content of the file `C:\temp\test.txt` from the line after `##Start` to the line before `##End`

## PARAMETERS

### -After

If passed then only content after this line will be returned, can be a line number or a string.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Before

If passed then only content before this line will be returned, can be a line number or a string.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FailIfNotFound

If specified will raise an exception if no results are found

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

### -Path

The path to the file to search

```yaml
Type: String[]
Parameter Sets: Path
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
