---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Get-OpenPullRequests

## SYNOPSIS
Gets the open Pull requests for a given repository

## SYNTAX

```
Get-OpenPullRequests -GitHubToken <String> [-GitHubOrg] <String> [-RepoName] <String> [<CommonParameters>]
```

## DESCRIPTION
Gets the open Pull requests for a given repository

## EXAMPLES

### EXAMPLE 1
```
Get-OpenPullRequests
    -GitHubUsername 'a_user' `
    -GitHubPAT 'abc-1234' `
    -GitHubOrganization 'acme' `
    -RepoName 'myRepo' `
```

This would fetch a list of open pull requests for the repo 'myRepo' belonging to the org/user 'acme'

## PARAMETERS

### -GitHubOrg
The GitHub org/user that owns the repository

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

### -RepoName
The repo name to check for PR's

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

