---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# New-GitHubBranch

## SYNOPSIS

Creates a new remote branch in a GitHub repository.

## SYNTAX

```text
New-GitHubBranch [-Token] <String> [-RepositoryOwner] <String> [-RepositoryName] <String>
 [-BranchName] <String> [-SHA] <String> [<CommonParameters>]
```

## DESCRIPTION

Uses the GitHub Git Data API to create a branch from a given commit SHA.

## EXAMPLES

### Example 1

```powershell
New-GitHubBranch -Token $GitHubToken -RepositoryOwner "Brownserve-UK" -RepositoryName "Brownserve.PSTools" -BranchName "release/v1.2.0" -SHA "abc1234"
```

Creates a new branch called `release/v1.2.0` in the `Brownserve-UK/Brownserve.PSTools` repository, branching from commit `abc1234`.

## PARAMETERS

### -BranchName

The name of the branch to create

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

### -SHA

The commit SHA to branch from

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
