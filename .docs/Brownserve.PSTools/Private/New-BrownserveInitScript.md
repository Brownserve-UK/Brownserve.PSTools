---
external help file: Brownserve.PSToolsPrivate-help.xml
Module Name: Brownserve.PSToolsPrivate
online version:
schema: 2.0.0
---

# New-BrownserveInitScript

## SYNOPSIS
Creates an _init.ps1 script from our template

## SYNTAX

```
New-BrownserveInitScript [-PermanentPaths] <InitPath[]> [-EphemeralPaths] <InitPath[]> [-IncludeModuleLoader]
 [[-CustomInitSteps] <String>] [<CommonParameters>]
```

## DESCRIPTION
Creates an _init.ps1 script from our template

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -CustomInitSteps
Any custom code that you would like to be included in the script

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EphemeralPaths
A list of ephemeral paths to be managed

```yaml
Type: InitPath[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeModuleLoader
If set will included our custom PowerShell module loader code

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

### -PermanentPaths
A list of permanent paths to manage

```yaml
Type: InitPath[]
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
