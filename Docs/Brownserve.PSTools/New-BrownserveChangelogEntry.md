---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# New-BrownserveChangelogEntry

## SYNOPSIS

Creates a new changelog entry for a given version in the standard Brownserve format.

## SYNTAX

```text
New-BrownserveChangelogEntry [[-ChangelogPath] <String>] [-Version] <SemanticVersion> -RepositoryOwner <String>
 -RepositoryName <String> [-GitHubToken <String>] [-Notice <String>] [-Features <String[]>]
 [-Bugfixes <String[]>] [-KnownIssues <String[]>] [-IssueLabelsToInclude <String[]>]
 [-IssueLabelsToExclude <String[]>] [-Auto] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will generate a new changelog entry in the standard Brownserve format.
Providing the -Auto parameter will cause the cmdlet to attempt to automatically populate the changelog entry with features, bugfixes and known issues
based on the GitHub pull requests and issues that have been open/closed since the last release.

## EXAMPLES

### Example 1: Automatically generate a changelog entry

```powershell
New-BrownserveChangelogEntry -RepositoryOwner "Brownserve-UK" -RepositoryName "Brownserve.PSTools" -Version 1.0.0 -Auto -GitHubToken $GitHubToken
```

This would generate a changelog entry for version 1.0.0 of the Brownserve.PSTools repository, automatically populating the features, bugfixes and known issues

## PARAMETERS

### -Auto

An optional flag to indicate that the cmdlet should attempt to automatically populate the changelog entry with features, bugfixes and known issues

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Bugfixes

An optional list of bugfixes to add to the changelog (these will be added alongside any auto-generated bugfixes)

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ChangelogPath

The path to the changelog file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $PWD
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### -Features

An optional list of features to add to the changelog (these will be added alongside any auto-generated features)

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -GitHubToken

The GitHub token to use for API calls

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -IssueLabelsToExclude

An optional list of labels to use to filter bug fixes/known issues when auto-generating the changelog entry

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -IssueLabelsToInclude

An optional list of labels to use to filter bug fixes/known issues when auto-generating the changelog entry

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -KnownIssues

An optional list of known issues to add to the changelog (these will be added alongside any auto-generated known issues)

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Notice

An optional notice to attach to this release, it will appear between the release header and the features section.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RepositoryName

The name of the repo that the changelog belongs to (e.g. Brownserve.PSTools)
This is used when auto-generating the changelog entry

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RepositoryOwner

The owner of the repo that the changelog belongs to (e.g. Brownserve-UK)
This is used when auto-generating the changelog entry

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Version

The version number to use for the new entry

```yaml
Type: SemanticVersion
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
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
