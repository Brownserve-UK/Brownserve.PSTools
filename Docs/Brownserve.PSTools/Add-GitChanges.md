---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Add-GitChanges

## SYNOPSIS
This cmdlet is a wrapper for the git command 'git add \<path\>'.

## SYNTAX

```
Add-GitChanges [-Path] <String[]> [[-RepositoryPath] <String>] [<CommonParameters>]
```

## DESCRIPTION
This command selects the git changes from the working tree to prepare the content staged for the next commit.

## EXAMPLES

### Example 1
```powershell
Set-Location -Path C:\MyGitRepo
Add-GitChanges -Path .\CHANGELOG.md
```

Would add the file CHANGELOG.md to the next commit in the git repository located at C:\MyGitRepo

## PARAMETERS

### -Path
The path(s) to the file(s) to be added to the next commit

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -RepositoryPath
The path to the git repository

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: $PWD
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
