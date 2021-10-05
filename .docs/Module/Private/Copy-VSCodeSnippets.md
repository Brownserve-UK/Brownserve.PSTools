---
external help file: Brownserve.PSToolsPrivate-help.xml
Module Name: Brownserve.PSToolsPrivate
online version:
schema: 2.0.0
---

# Copy-VSCodeSnippets

## SYNOPSIS
Copies our default VSCode snippets to a given repository

## SYNTAX

```
Copy-VSCodeSnippets [[-SnippetsSource] <String>] [-RepoPath] <String> [<CommonParameters>]
```

## DESCRIPTION
Copies our default VSCode snippets to a given repository

## EXAMPLES

### Example 1
```powershell
PS C:\> Copy-VSCodeSnippets C:\myRepo
```

Would copy our default snippets to c:\myRepo

## PARAMETERS

### -RepoPath
The repository to copy the snippets to

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

### -SnippetsSource
The snippet file to be copied

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
