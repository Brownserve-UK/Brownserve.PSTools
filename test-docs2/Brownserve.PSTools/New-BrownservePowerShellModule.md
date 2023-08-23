---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# New-BrownservePowerShellModule

## SYNOPSIS
Creates a new PowerShell module using the standard Brownserve format

## SYNTAX

```
New-BrownservePowerShellModule [-Path] <String> [-ModuleName] <String> [-ModuleGUID <Guid>]
 [-ModuleTags <String[]>] [-Description] <String> [[-Customisations] <String>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet creates a new custom PowerShell module using the standard format we use across our repos.

## EXAMPLES

### Example 1
```
PS C:\> New-BrownservePowerShellModule `
    -Path c:\temp\TestModule `
    -Name 'TestModule' `
    -Description 'My amazing module' `
    -Customisations '$foo = "bar"'
```

This would create a new module in the C:\temp\TestModule folder called \`TestModule.psm1\` with the supplied description and custom code.

## PARAMETERS

### -Customisations
Any custom code you want to provide to the module, of course this can always be added later.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Customizations

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
The description of the module, used to fill out the synopsis heading.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
If the module already exists then this will forcefully overwrite the module.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleGUID
The GUID to use for the module, if none provided one will be generated automatically

```yaml
Type: Guid
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleName
The name of the module to be created.

```yaml
Type: String
Parameter Sets: (All)
Aliases: name

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleTags
Optional set of tags to use for the module

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
The path to where the module will be saved (must be a directory)

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
