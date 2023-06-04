---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Get-GitRemoteOriginURL

## SYNOPSIS
Gets the remote origin URL for a given repository

## SYNTAX

```
Get-GitRemoteOriginURL [[-RepositoryPath] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Gets the remote origin URL for a given repository

## EXAMPLES

### Example 1
```powershell
Get-GitRemoteOriginURL 'C:\myRepo'
```

Would return the remote origin URL for the repo at `C:\myRepo`

## PARAMETERS

### -RepositoryPath
The path to the repository

```yaml
Type: String[]
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

## RELATED LINKS
