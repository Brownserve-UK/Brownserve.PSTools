---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# New-GitHubRelease

## SYNOPSIS
Creates a release on GitHub

## SYNTAX

```
New-GitHubRelease [-Name] <String> [-Tag] <String> [-Description] <String> [-RepositoryName] <String>
 [-RepositoryOwner] <String> -Token <String> [-Prerelease] [-TargetCommit <String>] [<CommonParameters>]
```

## DESCRIPTION
Creates a release on GitHub

## EXAMPLES

### EXAMPLE 1
```powershell
New-GitHubRelease `
    -Name "Version 1.0.0" `
    -Tag "v1.0.0" `
    -Description "This is the first release" `
    -RepoName "MyRepo" `
    -GitHubOrg "Acme" `
    -GitHubToken "my-token" `
```

This would create a release called "Version 1.0.0" with a tag of "v1.0.0"

## PARAMETERS

### -Description
The description for this release

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
The name of the release

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

### -Prerelease
Set if this is a prerelease

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RepositoryName
The name of the repository to create the release in

```yaml
Type: String
Parameter Sets: (All)
Aliases: RepoName

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RepositoryOwner
The owner of the repository to create the release in

```yaml
Type: String
Parameter Sets: (All)
Aliases: GitHubOrganisation, GitHubOrganization, GitHubOrg

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tag
The tag to use for the release, should not contain any whitespace.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetCommit
The target commitish to use (if any)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
