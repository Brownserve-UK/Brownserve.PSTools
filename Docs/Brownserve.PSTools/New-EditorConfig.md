---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# New-EditorConfig

## SYNOPSIS
Creates a new editorconfig configuration.

## SYNTAX

```
New-EditorConfig [[-IncludeRoot] <Boolean>] [-Section] <EditorConfigSection[]> [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will create a new editorconfig configuration.  
It does not output the configuration to disk, but rather returns the configuration as a string that can be piped to Set-Content or Out-File.

## EXAMPLES

### Example 1: Set Markdown files to use Unix line endings
```powershell
PS C:\> New-EditorConfig -Section @{
  Comment = 'Set Markdown files to use Unix line endings'
  FilePath = '*.md'
  Properties = @{
    EndOfLine = 'lf'
  }
}
```

This example creates a new editorconfig configuration that sets the end of line character for markdown files to Unix line endings.

## PARAMETERS

### -IncludeRoot
Whether or not to include the root editorconfig file

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: True
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Section
The section to add to the editorconfig file

```yaml
Type: EditorConfigSection[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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
