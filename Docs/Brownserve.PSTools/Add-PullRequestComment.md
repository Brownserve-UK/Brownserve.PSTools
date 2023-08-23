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

```
Add-PullRequestComment -GitHubToken <String> -GitHubOrg <String> [-PullRequestID] <String>
 [-PullRequestComment] <String> -RepoName <String> [<CommonParameters>]
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

### -GitHubOrg
The GitHub org/user that owns the repository you wish to submit the comment against.

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
The GitHub PAT that has permissions to add comments to PR's

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

### -PullRequestComment
The comment to be added to the PR

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

### -PullRequestID
The ID of the Pull Request

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
