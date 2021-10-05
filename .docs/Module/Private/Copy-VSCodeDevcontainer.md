---
external help file: Brownserve.PSToolsPrivate-help.xml
Module Name: Brownserve.PSToolsPrivate
online version:
schema: 2.0.0
---

# Copy-VSCodeDevcontainer

## SYNOPSIS
Copies a template devcontainer over to a given repo

## SYNTAX

```
Copy-VSCodeDevcontainer [[-DevcontainerTemplate] <String>] [-RepoPath] <String> [<CommonParameters>]
```

## DESCRIPTION
Copies a template devcontainer over to a given repo

## EXAMPLES

### Example 1
```powershell
PS C:\> Copy-VSCodeDevcontainer -RepoPath C:\myRepo
```

Would copy the devcontainer to C:\myRepo

## PARAMETERS

### -DevcontainerTemplate
The devcontainer to copy

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

### -RepoPath
The repo to copy the devcontainer to

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
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
