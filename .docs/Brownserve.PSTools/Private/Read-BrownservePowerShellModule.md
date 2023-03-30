---
external help file: Brownserve.PSToolsPrivate-help.xml
Module Name: Brownserve.PSToolsPrivate
online version:
schema: 2.0.0
---

# Read-BrownservePowerShellModule

## SYNOPSIS
Extracts content from a given PowerShell module 

## SYNTAX

```
Read-BrownservePowerShellModule [-ModulePath] <String> [<CommonParameters>]
```

## DESCRIPTION
We use a standard format for our PowerShell modules and this cmdlet will scan those modules to extract the relevant bits of data

## EXAMPLES

### Example 1
```powershell
Read-BrownservePowerShellModule -ModulePath C:\Brownserve.PSTools\Brownserve.PSTools.psm1
```

Would extract PowerShell module information from the Brownserve.PSTools module

## PARAMETERS

### -ModulePath
The path to the module

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
