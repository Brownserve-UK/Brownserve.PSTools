---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Submit-GitChanges

## SYNOPSIS

This cmdlet is a wrapper for \<git commit\>.

## SYNTAX

```text
Submit-GitChanges [-Message] <String> [[-RepositoryPath] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will commit all staged changes to the local repository.

## EXAMPLES

### Example 1

```powershell
Set-Location -Path C:\MyGitRepo
Submit-GitChanges -Message "This is a test commit"
```

Would commit all staged changes to the local repository located at C:\MyGitRepo with the message "This is a test commit"

## PARAMETERS

### -Message

The message to use for the commit.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -RepositoryPath

The path to the local repository.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path

Required: False
Position: 2
Default value: $PWD
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
