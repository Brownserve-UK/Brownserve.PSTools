---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Get-Vault

## SYNOPSIS
Downloads the given version of Vault for your OS

## SYNTAX

```
Get-Vault [[-VaultVersion] <Version>] [-DownloadPath] <String> [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will download the specified version of Vault to the given directory.  
An alias is created that replaces the path to the `vault` command and the environment variable `$env:VaultPath` is set to point to this downloaded version, this only affects your current PowerShell session.

This allows us to lock vault to different versions across projects if we need to.

## EXAMPLES

### EXAMPLE 1: Using the default version
```powershell
Get-Vault -DownloadPath 'C:\Tools'
```

Will download vault to C:\Tools

### EXAMPLE 2: Using the parameters
```powershell
Get-Vault -VaultVersion '1.7.3' -DownloadPath 'C:\Tools'
```

Will download v.1.7.3 to C:\Tools

## PARAMETERS

### -DownloadPath
The path to download the binary to

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VaultVersion
The version of Vault to use  

```yaml
Type: Version
Parameter Sets: (All)
Aliases:

Required: False
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
$env:VaultPath will be set upon successful download/extraction of Vault and the command 'vault' will be set to the
downloaded version of vault for this session.

## RELATED LINKS
