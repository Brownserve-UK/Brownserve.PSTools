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

```
Get-GitHubRelease [-RepoName] <String> [-GitHubOrg] <String> -GitHubToken <String> [<CommonParameters>]
```

## DESCRIPTION
Gets a list of releases from a given GitHub repo

## EXAMPLES

### EXAMPLE 1
```
Get-GitHubRelease `
    -RepoName "MyRepo" `
    -GitHubOrg "Acme" `
    -GitHubToken "my-token"
```

Would get all releases from the \`Acme/MyRepo\` repository

## PARAMETERS

### -GitHubOrg
The GitHub org/user that owns the repository

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
The PAT to access the repo

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
The GitHub repo to create the release against

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

