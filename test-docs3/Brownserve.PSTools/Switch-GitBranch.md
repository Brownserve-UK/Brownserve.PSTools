---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version: https://api.slack.com/messaging/composing/layouts
schema: 2.0.0
---

# Switch-GitBranch

## SYNOPSIS
Checks out a given branch.

## SYNTAX

```
Switch-GitBranch [[-RepositoryPath] <String>] [-BranchName] <String> [<CommonParameters>]
```

## DESCRIPTION
Checks out a given branch.

## EXAMPLES

### Example 1
```
Switch-GitBranch -RepositoryPath 'C:\myRepo' -BranchName 'my_branch'
```

Would checkout the branch \`my_branch\`

## PARAMETERS

### -BranchName
The branch to checkout

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

