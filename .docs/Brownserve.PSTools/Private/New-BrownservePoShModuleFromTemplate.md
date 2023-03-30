---
external help file: Brownserve.PSToolsPrivate-help.xml
Module Name: Brownserve.PSToolsPrivate
online version:
schema: 2.0.0
---

# New-BrownservePoShModuleFromTemplate

## SYNOPSIS
Creates a custom PowerShell module from a template file.

## SYNTAX

```
New-BrownservePoShModuleFromTemplate [[-Description] <String>] [[-Customisations] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Creates a custom PowerShell module from a template file.

## EXAMPLES

### Example 1
```powershell
New-BrownservePoShModuleFromTemplate -Description 'Test module' -Customisations '$foo = "bar"'
```

Would create a module with the above details.

## PARAMETERS

### -Customisations
Any customisations to be provided to the module

```yaml
Type: String
Parameter Sets: (All)
Aliases: Customizations

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
The description of the module

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
