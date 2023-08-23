---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version: https://api.slack.com/messaging/composing/layouts
schema: 2.0.0
---

# Update-Changelog

## SYNOPSIS
Updates a repo's changelog according to the semver v1.0.0 spec.

## SYNTAX

```
Update-Changelog [-ChangelogPath] <String> [-ReleaseType <String>] [-Features <Array>] [-Bugfixes <Array>]
 [-KnownIssues <Array>] [-RepoUrl <String>] [-AutoGenerateFeatures] [-SkipOptionalPrompts] [<CommonParameters>]
```

## DESCRIPTION
Updates a repo's changelog according to the semver v1.0.0 spec.

This is a completely guided cmdlet and the user will be prompted to provide all necessary information, the cmdlet can also be run programmatically by passing in the required parameters.

## EXAMPLES

### EXAMPLE 1: Guided input
```
Update-Changelog -ChangelogPath C:\CHANGELOG.md
```

This would prompt the user for all information and then update the changelog at 'C:\CHANGELOG.md'

### EXAMPLE 2: Providing all information in parameters
```
Update-Changelog `
    -ChangelogPath C:\CHANGELOG.md `
    -ReleaseType 'major' `
    -Features "my feature 1","my feature 2" `
    -BugFixes "Fixed bug 1" `
    -KnownIssues "Bug 2 still a problem"
```

As all required and optional information has been provided the changelog at 'C:\CHANGELOG.md' would be updated with the provided information

### EXAMPLE 3: Skipping optional prompts and auto generating feature list
```
Update-Changelog `
    -ChangelogPath C:\CHANGELOG.md `
    -ReleaseType 'major' `
    -AutoGenerateFeatures `
    -SkipOptionalPrompts
```

As all required information has been provided and \`SkipOptionalPrompts\` has been passed the changelog at 'C:\CHANGELOG.md' would be updated with the provided information.

As \`AutoGenerateFeatures\` was also passed the feature list will be generated from this branches commit history

## PARAMETERS

### -AutoGenerateFeatures
If set will attempt to auto-generate features from the commit history (ignored if $Features are passed into the cmdlet)

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

### -Bugfixes
Any bugfixes in this release

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ChangelogPath
The path to the changelog file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: True
```

### -Features
The feature list for this release

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KnownIssues
Any known issues in this release

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReleaseType
The type of release (major, minor, patch)

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: major, minor, patch

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RepoUrl
The URL of the repo that the changelog belongs to If none is provided the cmdlet will attempt to work it out from the current changelog and prompt if needed

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SkipOptionalPrompts
Skip optional prompts

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
