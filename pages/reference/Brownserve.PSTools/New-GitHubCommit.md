---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# New-GitHubCommit

## SYNOPSIS

Creates a commit on a GitHub repository branch via the GitHub API.

## SYNTAX

```text
New-GitHubCommit [-Token] <String> [-RepositoryOwner] <String> [-RepositoryName] <String>
 [-BranchName] <String> [-CommitMessage] <String> [-Files] <Hashtable[]>
 [<CommonParameters>]
```

## DESCRIPTION

Uses the GitHub Git Data API to create a commit containing one or more file changes.
Commits created via this method are automatically marked as Verified by GitHub,
with no GPG or SSH signing key required.
The Files parameter expects an array of hashtables each containing a 'Path' key
(repo-root-relative, forward-slash separated) and a 'Content' key (raw file text).

## EXAMPLES

### Example 1

```powershell
$Files = @(
    @{ Path = 'CHANGELOG.md'; Content = (Get-Content -Path './CHANGELOG.md' -Raw) }
)
New-GitHubCommit -Token $GitHubToken -RepositoryOwner "Brownserve-UK" -RepositoryName "Brownserve.PSTools" -BranchName "release/v1.2.0" -CommitMessage "docs: update changelog for v1.2.0" -Files $Files
```

Creates a commit on the `release/v1.2.0` branch containing an updated `CHANGELOG.md`. The commit is automatically marked as Verified by GitHub.

## PARAMETERS

### -BranchName

The branch to commit to

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -CommitMessage

The commit message

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Files

The files to include in the commit.
Each hashtable must have 'Path' and 'Content' keys.

```yaml
Type: Hashtable[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RepositoryName

The repository name

```yaml
Type: String
Parameter Sets: (All)
Aliases: RepoName

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RepositoryOwner

The org/user that owns the repository

```yaml
Type: String
Parameter Sets: (All)
Aliases: GitHubOrganisation, GitHubOrganization, GitHubOrg

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Token

The GitHub token used to authenticate

```yaml
Type: String
Parameter Sets: (All)
Aliases: GitHubToken, GitHubPAT

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
