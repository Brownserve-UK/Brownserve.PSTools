---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Update-PlatyPSModulePageDescription

## SYNOPSIS
Updates the PlatyPS module page module description field.

## SYNTAX

```
Update-PlatyPSModulePageDescription [-ModuleDescription] <String> [-ModulePagePath] <String>
 [<CommonParameters>]
```

## DESCRIPTION
The Update-MarkdownHelpModule cmdlet in the PlatyPS module doesn't support updating the module description in the module
page.
This cmdlet will set the module description in the module page to the description specified.
.

## EXAMPLES

### Example 1
```powershell
Update-PlatyPSModulePageDescription -ModuleDescription "This is a test" -ModulePagePath 'C:\MyModule\docs\en-US\MyModule.md'
```

This would update the module description in the module page located at `C:\MyModule\docs\en-US\MyModule.md` to "This is a test"

## PARAMETERS

### -ModuleDescription
The description to set in the module page.

```yaml
Type: String
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
