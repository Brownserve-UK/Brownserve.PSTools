---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Get-GitHubTags

## SYNOPSIS
Gets a list of tags for a given GitHub repository

## SYNTAX

```
Get-GitHubTags [-RepoName] <String> [-GitHubOrg] <String> -GitHubToken <String> [<CommonParameters>]
```

## DESCRIPTION
Gets a list of tags for a given GitHub repository

## EXAMPLES

### Example 1
```powershell
Get-GitHubTags -GitHubOrg 'myOrg' -GitHubToke $GitHubToken -RepoName 'myRepo'
```

This would fetch all the tags for the repository "myRepo" which lives in the GitHubOrg "myOrg"

## PARAMETERS

### -GitHubOrg
The organisation/owner that houses the repository you wish to query

```yaml
Type: String
Parameter Sets: (All)
Aliases: GitHubOrganisation, GitHubOrganization

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GitHubToken
The token with the relevant permissions to access the repository

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
The name of the repo to query

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
