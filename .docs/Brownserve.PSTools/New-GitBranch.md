---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# New-GitBranch

## SYNOPSIS
Creates a new branch in a given git repository

## SYNTAX

```
New-GitBranch [[-RepositoryPath] <String>] [-BranchName] <String> [[-Checkout] <Boolean>] [<CommonParameters>]
```

## DESCRIPTION
Creates a new branch in a given git repository, you can optionally checkout the new branch after creation.

## EXAMPLES

### Example 1: Create a new branch
```powershell
New-GitBranch -RepositoryPath 'C:\myRepo' -BranchName 'new_branch'
```

Would create a new branch in the `C:\myRepo` repository called `new_branch`.
Upon successful creation it would be checked out.

## PARAMETERS

### -BranchName
The name of the branch to create

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

### -Checkout
If set to `$true` will checkout the branch after creation

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -RepositoryPath
The path to the repository

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
