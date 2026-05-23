---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Push-GitChanges

## SYNOPSIS

Pushes local git changes to the remote repository.

## SYNTAX

```text
Push-GitChanges [-BranchName] <String> [[-RepositoryPath] <String>] [[-RemoteName] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

This cmdlet pushes local git changes to the remote repository.

## EXAMPLES

### Example 1

```powershell
Set-Location -Path C:\MyGitRepo
Push-GitChanges -BranchName main
```

Would push the local changes to the main branch of the remote repository located at C:\MyGitRepo

## PARAMETERS

### -BranchName

The name of the branch to push

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RemoteName

The name of the remote repository (defaults to 'origin')

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Origin
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RepositoryPath

The path to the repository

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $PWD
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
