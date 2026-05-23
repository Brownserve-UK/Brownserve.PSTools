---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Get-GitChanges

## SYNOPSIS

Gets the git status for a given repository

## SYNTAX

```text
Get-GitChanges [[-Path] <String>] [-UsePorcelain] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet gets the git status for a given repository. It will return a list of files along with the type of change that has been made to them.
This cmdlet has been named in such a way so as not to conflict with `Get-GitStatus` from the posh-git module.

## EXAMPLES

### Example 1

```powershell
Get-GitChanges -Path C:\MyRepo
```

This will return a list of files that have been changed in the repository at `C:\MyRepo`

## PARAMETERS

### -Path

The path to the git repository to get the status of. If not specified, the current directory will be used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: $PWD
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -UsePorcelain

By default this cmdlet uses the `git status -s` command to query the status of the repository. The output of this command could potentially change between versions of git. The `-UsePorcelain` switch will instead use the `git status --porcelain` command which is designed to remain consistent between versions of git.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.Management.Automation.SwitchParameter

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
