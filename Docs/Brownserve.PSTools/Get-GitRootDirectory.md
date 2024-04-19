---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Get-GitRootDirectory

## SYNOPSIS

Returns the root directory of a git repository.

## SYNTAX

```text
Get-GitRootDirectory [[-RepositoryPath] <String[]>] [<CommonParameters>]
```

## DESCRIPTION

Returns the root directory of a git repository.

## EXAMPLES

### Example 1

```powershell
 Get-GitRootDirectory
```

Returns the root directory of the git repository in the current directory.

### Example 2

```powershell
Get-GitRootDirectory -RepositoryPath C:\myRepo\SomeDirectory
```

Returns the root directory of the git repository in the specified directory.
In this case, the root directory is C:\myRepo.

## PARAMETERS

### -RepositoryPath

The path to the git repository. If not specified, the current directory is used.

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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
