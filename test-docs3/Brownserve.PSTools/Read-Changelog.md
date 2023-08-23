---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Read-Changelog

## SYNOPSIS
Retrieves version information and release notes from a CHANGELOG.md file.

## SYNTAX

```
Read-Changelog [-ChangelogPath] <String> [[-VersionPattern] <String>] [[-RepoURLPattern] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Retrieves version information and release notes from a CHANGELOG.md file.
This is done by searching for a regex match (defaults to semver 1.0.0) and extracting all information between the current release and the previous release

## EXAMPLES

### EXAMPLE 1
```
Read-Changelog -ChangelogPath C:\repos\MyRepo\CHANGELOG.md
```

Returns version number and release notes from the changelog at 'C:\repos\MyRepo\CHANGELOG.md'

## PARAMETERS

### -ChangelogPath
The path of the release notes.md file to read from, wildcards are permitted.

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

### -RepoURLPattern
The regex pattern for matching the repo URL.
It should always contain a capture group named "url" and this what the regex searched will use to extract your url

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

### -VersionPattern
The regex to use for version matching.
It should always contain a capture group named "version" as this is what the regex matcher will use to extract the version number

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES
The resulting object from this cmdlet can be piped into Add-ChangelogEntry for convenience.

## RELATED LINKS
