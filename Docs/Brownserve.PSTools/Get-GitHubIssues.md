---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Get-GitHubIssues

## SYNOPSIS
Gets the issues for a given GitHub repository

## SYNTAX

```
Get-GitHubIssues [-GitHubToken] <String> [-RepositoryOwner] <String> [-RepositoryName] <String>
 [[-State] <GitHubIssueState>] [<CommonParameters>]
```

## DESCRIPTION
Gets the issues for a given GitHub repository

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-GitHubIssues -GitHubToken $GitHubToken -RepositoryOwner 'Brownserve-UK' -RepositoryName 'Brownserve.PSTools'
```

This will return all _open_ issues for the Brownserve.PSTools repository

## PARAMETERS

### -GitHubToken
The GitHub token to use for authentication

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
The name of the repository to get the issues for

```yaml
Type: String
Parameter Sets: (All)
Aliases: RepoName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RepositoryOwner
The owner of the repository to get the issues for

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

### -State
The state of the issues to get. Valid values are Open, Closed and All

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
