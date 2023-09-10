---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Add-GitHubReleaseAsset

## SYNOPSIS
Uploads a file to a GitHub release.

## SYNTAX

```
Add-GitHubReleaseAsset [-FilePath] <String> [[-AssetName] <String>] [[-AssetLabel] <String>]
 [-UploadUrl] <String> [-Token] <String> [<CommonParameters>]
```

## DESCRIPTION
This will upload a local file to a given GitHub release.

## EXAMPLES

### Example 1: Upload a file
```powershell
$ReleaseInfo = Get-GitHubRelease `
  -RepositoryOwner 'Brownserve-UK' `
  -RepositoryName 'Brownserve.PSTools' `
  -Token $token | Select-Object -First 1
Add-GitHubReleaseAsset `
  -FilePath C:\myFile.zip `
  -UploadURL $ReleaseInfo.upload_url `
  -Token $token
```

This would upload the release asset `myFile.zip` to the latest release on the `Brownserve.PSTools` repository

### Example 2: Use a custom name for the release asset
```powershell
$ReleaseInfo = Get-GitHubRelease `
  -RepositoryOwner 'Brownserve-UK' `
  -RepositoryName 'Brownserve.PSTools' `
  -Token $token | Select-Object -First 1
Add-GitHubReleaseAsset `
  -FilePath C:\myFile.zip `
  -AssetName 'PowerShellModule.zip'`
  -UploadURL $ReleaseInfo.upload_url `
  -Token $token
```

This would upload the release asset `myFile.zip` as `PowerShellModule.zip` to the latest release on the `Brownserve.PSTools` repository

### Example 3: Use a label for the asset name
```powershell
$ReleaseInfo = Get-GitHubRelease `
  -RepositoryOwner 'Brownserve-UK' `
  -RepositoryName 'Brownserve.PSTools' `
  -Token $token | Select-Object -First 1
Add-GitHubReleaseAsset `
  -FilePath C:\myFile.zip `
  -AssetLabel 'Compressed PowerShell module'`
  -UploadURL $ReleaseInfo.upload_url `
  -Token $token
```

This would upload the release asset `myFile.zip` as `Compressed PowerShell module` to the latest release on the `Brownserve.PSTools` repository

## PARAMETERS

### -AssetLabel
An optional label for the asset, used in place of the file name when displaying the asset on the GitHub release page however the name of the downloaded file remains the same as passed to the `-AssetName` parameter.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AssetName
Determines the name of the asset on GitHub.  
Defaults to the name of the file passed to `-FilePath`
**Remember to include the file extension if setting this manually**

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FilePath
The path to the file to upload.

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

### -Token
The GitHub API token to use.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -UploadUrl
The upload URL for the release.  
This can be acquired via `Get-GitHubRelease`

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
