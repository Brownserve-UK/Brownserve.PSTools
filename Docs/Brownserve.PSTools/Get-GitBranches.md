---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Get-GitBranches

## SYNOPSIS

Gets the current branches for the given repository

## SYNTAX

```text
Get-GitBranches [[-RepositoryPath] <String>] [<CommonParameters>]
```

## DESCRIPTION

Gets the current branches for the given repository

## EXAMPLES

### Example 1

```powershell
Get-GitBranches 'C:\myRepo'
```

Would return the branches from `C:\myRepo`

## PARAMETERS

### -RepositoryPath

The path to the repository to get the branches for

```yaml
Type: String
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
