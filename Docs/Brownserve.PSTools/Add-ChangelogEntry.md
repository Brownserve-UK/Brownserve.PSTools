---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Add-ChangelogEntry

## SYNOPSIS

**This cmdlet is deprecated. Please use Add-BrownserveChangelogEntry instead.**
Inserts a new changelog entry into a given changelog file

## SYNTAX

```text
Add-ChangelogEntry [-ChangelogPath] <String> [-NewContent] <String> [<CommonParameters>]
```

## DESCRIPTION

Inserts a new changelog entry into a given changelog file

## EXAMPLES

### EXAMPLE 1: Add a changelog entry

```powershell
Add-ChangelogEntry -ChangelogPath C:\CHANGELOG.md -NewContent "This is a test"
```

Would enter the value "This is a test" at the top of the changelog located at `C:\CHANGELOG.md\`

### EXAMPLE 2: Add a changelog entry from pipeline

```powershell
Read-Changelog -ChangelogPath C:\CHANGELOG.md | Add-ChangelogEntry -NewContent "This is a test"
```

Would enter the value "This is a test" at the top of the changelog located at `C:\CHANGELOG.md`

## PARAMETERS

### -ChangelogPath

The path to the changelog file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### -NewContent

The content to be inserted into the changelog

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.Management.Automation.PSObject

## OUTPUTS

### System.Object

## NOTES

You can pipe new content directly into this cmdlet from Read-Changelog for ease of use

## RELATED LINKS
