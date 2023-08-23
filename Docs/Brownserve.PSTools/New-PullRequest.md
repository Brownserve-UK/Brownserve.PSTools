---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# New-PullRequest

## SYNOPSIS
Creates a new pull request in GitHub

## SYNTAX

```
New-PullRequest -GitHubToken <String> -GitHubOrg <String> [-PRBody] <String> [-PRTitle] <String>
 [-BaseBranch] <String> [-HeadBranch] <String> -RepoName <String> [<CommonParameters>]
```

## DESCRIPTION
Creates a new pull request in GitHub

## EXAMPLES

### EXAMPLE 1
```powershell
New-PullRequest
    -GitHubUsername 'a_user' `
    -GitHubPAT 'abc-1234' `
    -GitHubOrganization 'acme' `
    -RepoName 'myRepo' `
    -BaseBranch 'main' `
    -HeadBranch 'my-feature-branch' `
    -PRTitle 'Add new feature' `
    -PRBody 'This adds my new feature to main'
```

This would create a new PR against acme/myRepo with a goal to merge 'my-feature-branch' into 'main'.
The PR would be titled 'Add new feature' and would contain a comment of 'This adds my new feature to main'

## PARAMETERS

### -BaseBranch
The branch you want to pull changes into

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

### -GitHubOrg
The GitHub org/user that owns the repository

```yaml
Type: String
Parameter Sets: (All)
Aliases: GitHubOrganisation, GitHubOrganization

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -GitHubToken
The GitHub PAT

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -HeadBranch
Your feature branch that you want to merge into your base branch

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

### -PRBody
The body of the pull request

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

### -PRTitle
The title of the pull request

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

### -RepoName
The name of the repo

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
