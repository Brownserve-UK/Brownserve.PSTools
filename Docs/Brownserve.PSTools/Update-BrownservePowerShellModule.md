---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Update-BrownservePowerShellModule

## SYNOPSIS

Updates a given Brownserve PowerShell module to use the latest template.

## SYNTAX

```text
Update-BrownservePowerShellModule [-Path] <String> [[-Description] <String>] [[-Customisations] <String>]
 [-Force] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet will update a given PowerShell module that uses our standard Brownserve format to use the latest template while attempting to maintain any customisations the user has made.

## EXAMPLES

### Example 1

```powershell
PS C:\> Update-BrownservePowerShellModule -Path C:\Brownserve.PSTools.psm1
```

This would update the module at the given path.

## PARAMETERS

### -Customisations

A string containing any custom code you want to add to the module, if the existing module already contains customisations an error will be raised.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Customizations

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description

An option synopsis for the module, if one is already present in the module an error will be raised.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

Forcefully overwrite any customisations or description that already exist in the module.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

The path to the module.

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
