---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Update-BrownserveRepository

## SYNOPSIS
Updates a given repository to use the latest tooling and settings

## SYNTAX

```
Update-BrownserveRepository [-RepoPath] <String> [-ProjectType <BrownserveRepoProjectType>]
 [<CommonParameters>]
```

## DESCRIPTION
This cmdlet can be used after a repository has been initialised using the `Initialize-BrownserveRepository` cmdlet to keep the projects tooling and settings up to date.

## EXAMPLES

### Example 1
```powershell
Update-BrownserveRepository -RepoPath 'C:\myPowershellModule' -ProjectType 'PowerShellModule'
```

Would update the project at 'C:\myPowershellModule'

## PARAMETERS

### -ProjectType
The type of project this repository holds

```yaml
Type: BrownserveRepoProjectType
Parameter Sets: (All)
Aliases:
Accepted values: PowerShellModule, BrownservePSTools, Generic

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RepoPath
The path to the repository to be updated

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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
