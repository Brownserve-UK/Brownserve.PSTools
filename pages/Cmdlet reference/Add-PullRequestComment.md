---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Add-PullRequestComment

## SYNOPSIS

Adds a comment to a given pull request

## SYNTAX

```text
Add-PullRequestComment -Token <String> -RepositoryOwner <String> [-PullRequestID] <String>
 [-PullRequestComment] <String> -RepositoryName <String>
 [<CommonParameters>]
```

## DESCRIPTION

Adds a comment to a given pull request

## EXAMPLES

### EXAMPLE 1

```powershell
Add-PullRequestComment `
    -GitHubUsername 'a_user' `
    -GitHubPAT 'abc-1234' `
    -GitHubOrganization 'acme' `
    -RepoName 'myRepo' `
    -PullRequestID '1122' `
    -PullRequestComment 'Hello, world!'
```

This would add the comment 'Hello, world!' to pull request \`1122\` on the repo 'myRepo' belonging to the user/org 'acme'

## PARAMETERS

### -PullRequestComment

The comment to be added to the PR

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PullRequestID

The ID of the Pull Request

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RepositoryName

The name of the repository that the pull request belongs to

```yaml
Type: String
Parameter Sets: (All)
Aliases: RepoName

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RepositoryOwner

The owner of the repository that the pull request belongs to

```yaml
Type: String
Parameter Sets: (All)
Aliases: GitHubOrganisation, GitHubOrganization, GitHubOrg

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Token

The GitHub Personal Access Token to use for authentication

```yaml
Type: String
Parameter Sets: (All)
Aliases: GitHubToken, GitHubPAT

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
