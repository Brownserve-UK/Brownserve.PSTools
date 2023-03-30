---
external help file: Brownserve.PSToolsPrivate-help.xml
Module Name: Brownserve.PSToolsPrivate
online version:
schema: 2.0.0
---

# New-ChangelogBlock

## SYNOPSIS
Creates a new changelog entry text block in the expected format for a semver changelog.

## SYNTAX

```
New-ChangelogBlock [-Version] <Version> [-RepoURL] <String> [-Features] <Array> [[-Bugfixes] <Array>]
 [[-KnownIssues] <Array>] [<CommonParameters>]
```

## DESCRIPTION
Creates a new changelog entry text block in the expected format for a semver changelog.
This cmdlet accepts arrays of features, bugfixes and know issues and formats them into the correct format for our changelogs

## EXAMPLES

### EXAMPLE 1
```powershell
New-ChangelogEntry `
    -Version ([version]"0.1.0") `
    -RepoUrl "https://github.com/myorg/myrepo" `
    -Features "My cool new feature", "My other cool feature" `
    -KnowIssues "My cool new feature returns too many cats"
```

This would export a changelog block with the desired parameters.

## PARAMETERS

### -Bugfixes
Any bugfixes that have been introduced in this version

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Features
The new features that have been added in this version

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -KnownIssues
Any known issues

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RepoURL
The URL to the repo

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Version
The version number

```yaml
Type: Version
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Version

### System.String

### System.Array

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
