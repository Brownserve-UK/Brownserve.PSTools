---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Get-GitHubRelease

## SYNOPSIS

Gets a list of releases from a given GitHub repo

## SYNTAX

```text
Get-GitHubRelease [-RepositoryOwner] <String> [-RepositoryName] <String> [-Token] <String>
 [<CommonParameters>]
```

## DESCRIPTION

Gets a list of releases from a given GitHub repo

## EXAMPLES

### EXAMPLE 1

```powershell
Get-GitHubRelease `
    -RepoName "MyRepo" `
    -GitHubOrg "Acme" `
    -GitHubToken "my-token"
```

Would get all releases from the `Acme/MyRepo` repository

## PARAMETERS

### -RepositoryName

The name of the repository to query for releases

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

The owner of the repository

```yaml
Type: String
Parameter Sets: (All)
Aliases: GitHubOrganisation, GitHubOrganization, GitHubOrg

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Token

GitHub access token

```yaml
Type: String
Parameter Sets: (All)
Aliases: GitHubToken, GitHubPAT

Required: True
Position: 0
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
