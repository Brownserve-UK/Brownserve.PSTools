---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Copy-GitRemoteRepository

## SYNOPSIS
Clones a given git repository to the local machine

## SYNTAX

```
Copy-GitRemoteRepository [-URI] <String> [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION
Clones a given git repository to the local machine

## EXAMPLES

### Example 1
```powershell
Copy-GitRemoteRepository 'git@github.com:Brownserve-UK/Brownserve.PSTools.git' 'C:\MyRepos\'
```

Would clone the Brownserve.PSTools repository to `C:\MyRepos\Brownserve.PSTools`

## PARAMETERS

### -Path
The directory in which to store the repository, a child directory will be made for the repository

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -URI
The URI to the remote repository to clone

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
