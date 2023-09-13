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

```text
Get-GitHubTags [-RepositoryName] <String> [-RepositoryOwner] <String> -Token <String> [<CommonParameters>]
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

### -RepositoryName

The name of the repository to query

```yaml
Type: String
Parameter Sets: (All)
Aliases: RepoName

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RepositoryOwner

The owner of the repository to query

```yaml
Type: String
Parameter Sets: (All)
Aliases: GitHubOrganisation, GitHubOrganization, GitHubOrg

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Token

The GitHub PAT

```yaml
Type: String
Parameter Sets: (All)
Aliases: GitHubToken, GitHubPAT

Required: True
Position: Named
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
