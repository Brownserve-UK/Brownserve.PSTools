---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Get-GitHubPullRequests

## SYNOPSIS
Gets pull request information from a given GitHub repository.

## SYNTAX

```
Get-GitHubPullRequests -GitHubToken <String> [-GitHubOrg] <String> [-RepoName] <String>
 [[-State] <GitHubIssueState>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will return a list of pull requests from a given GitHub repository.  
You are able to get both open and closed pull requests.

## EXAMPLES

### Example 1: Open Pull Requests
```powershell
Get-GitHubPullRequests -GitHubToken $MyToken -GitHubOrg "Brownserve-UK" -RepoName "Brownserve.PSTools" -State Open
```

This would return all open pull requests from the `Brownserve-UK/Brownserve.PSTools` repository

### Example 2: Closed Pull Requests
```powershell
Get-GitHubPullRequests -GitHubToken $MyToken -GitHubOrg "Brownserve-UK" -RepoName "Brownserve.PSTools" -State Closed
```

This would return all closed/merged pull requests from the `Brownserve-UK/Brownserve.PSTools` repository

### Example 3: All Pull Requests
```powershell
Get-GitHubPullRequests -GitHubToken $MyToken -GitHubOrg "Brownserve-UK" -RepoName "Brownserve.PSTools" -State All
```

This would return all open, closed and merged pull requests from the `Brownserve-UK/Brownserve.PSTools` repository

## PARAMETERS

### -GitHubOrg
The owner of the GitHub repository

```yaml
Type: String
Parameter Sets: (All)
Aliases: GitHubOrganisation, GitHubOrganization

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -GitHubToken
The token with read permissions against the repository

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

### -RepoName
The name of the repository

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

### -State
The type of pull requests to retrieve

```yaml
Type: GitHubIssueState
Parameter Sets: (All)
Aliases:
Accepted values: Open, Closed, All

Required: False
Position: 3
Default value: Open
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### GitHubIssueState
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
