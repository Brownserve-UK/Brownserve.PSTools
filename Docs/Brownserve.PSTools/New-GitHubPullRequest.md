---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# New-GitHubPullRequest

## SYNOPSIS

Creates a new GitHub pull request

## SYNTAX

```text
New-GitHubPullRequest -Token <String> -RepositoryOwner <String> [-Body] <String> [-Title] <String>
 [-BaseBranch] <String> [-HeadBranch] <String> -RepositoryName <String> [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will create a new GitHub pull request

## EXAMPLES

### Example 1

```powershell
New-GitHubPullRequest -Token $GitHubToken -RepositoryOwner "Brownserve-UK" -RepositoryName "Brownserve.PSTools" -Title "This is a test" -Body "This is a test" -BaseBranch "main" -HeadBranch "test"
```

This would create a new pull request in the `Brownserve-UK/Brownserve.PSTools` repository with the title "This is a test" and the body "This is a test"

## PARAMETERS

### -BaseBranch

The branch you want to pull changes into

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

### -Body

The body (message content) of the pull request

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

### -HeadBranch

Your feature branch that you want to merge into your base branch

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RepositoryName

The name of the repository to create the pull request in

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

The owner of the repository you want to create the pull request in

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

### -Title

The title of the pull request

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

### -Token

The token to use for authentication

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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
