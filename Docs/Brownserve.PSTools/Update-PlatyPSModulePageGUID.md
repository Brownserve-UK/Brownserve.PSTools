---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Update-PlatyPSModulePageGUID

## SYNOPSIS
Updates the module GUID in the PlatyPS module page.

## SYNTAX

```
Update-PlatyPSModulePageGUID [-ModuleGUID] <Guid> [-ModulePagePath] <String> [<CommonParameters>]
```

## DESCRIPTION
The Update-MarkdownHelpModule cmdlet in the PlatyPS module doesn't support updating the module GUID in the module
page.
This cmdlet will check the module manifest for the GUID and update the module GUID in the module page.

## EXAMPLES

### Example 1
```powershell
Update-PlatyPSModulePageGUID -ModuleGUID '00000000-0000-0000-0000-000000000000' -ModulePagePath 'C:\MyModule\docs\en-US\MyModule.md'
```

This would update the module GUID in the module page located at `C:\MyModule\docs\en-US\MyModule.md` to '00000000-0000-0000-0000-000000000000'

## PARAMETERS

### -ModuleGUID
The GUID of the module

```yaml
Type: Guid
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ModulePagePath
The path to the module page

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
