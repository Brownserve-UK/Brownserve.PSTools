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

```text
Set-LineEndings [-Path] <String[]> [[-LineEnding] <String>] [<CommonParameters>]
```

## DESCRIPTION

Currently PowerShell does not have a built in way to set the line endings of a file when using `Set-Content`, `New-Item` etc.
This cmdlet provides a way to post-process a file to force the line endings to be a single desired type.
This cmdlet can likely be retired once [PowerShell#2872](https://github.com/PowerShell/PowerShell/issues/2872) is resolved.

## EXAMPLES

### Example 1: Set the line endings of a file to CRLF

```powershell
PS C:\> Set-LineEndings -Path C:\Temp\test.txt -LineEnding CRLF
```

This command will set the line endings of the file C:\Temp\test.txt to CRLF

### Example 2: Set the line endings of a file to LF

```powershell
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
