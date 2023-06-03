---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Assert-Command

## SYNOPSIS
Ensures the given command exists and is available to the current PowerShell session

## SYNTAX

```
Assert-Command [-Command] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Ensures the given command exists and is available to the current PowerShell session

## EXAMPLES

### Example 1: Command that is present
```powershell
Assert-Command 'pwsh'
```

This command would pass successfully as the command exists

### Example 2: Command that is not present
```powershell
Assert-Command 'notArealCommand'
```

This command would return a terminating error as the command doesn't exist

### Example 3: Check multiple commands
```powershell
Assert-Command 'notArealCommand', 'pwsh'
```

This command would return a terminating error as one of the commands does not exist

## PARAMETERS

### -Command
The command(s) to be checked

```yaml
Type: String[]
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
