---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Get-GitCurrentBranch

## SYNOPSIS
Gets the current branch for a given repository

## SYNTAX

```
Get-GitCurrentBranch [[-RepositoryPath] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Gets the current branch for a given repository

## EXAMPLES

### Example 1
```powershell
Get-GitCurrentBranch 'C:\myRepo'
```

Would get the current branch for the repo `c:\myRepo`

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
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
