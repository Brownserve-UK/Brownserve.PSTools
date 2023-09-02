---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Update-PlatyPSModulePageHelpVersion

## SYNOPSIS
Updates the help version in the PlatyPS module page.

## SYNTAX

```
Update-PlatyPSModulePageHelpVersion [-HelpVersion] <SemanticVersion> [-ModulePagePath] <String>
 [<CommonParameters>]
```

## DESCRIPTION
The Update-MarkdownHelpModule cmdlet in the PlatyPS module doesn't support updating the help version in the module
page.
This cmdlet will check the module manifest for the version number header and update the help version to the version
specified.
This allows us to keep our help version and module version in sync.

## EXAMPLES

### Example 1
```powershell
Update-PlatyPSModulePageHelpVersion -HelpVersion '1.0.0' -ModulePagePath 'C:\MyModule\docs\en-US\MyModule.md'
```

This would update the help version in the module page located at `C:\MyModule\docs\en-US\MyModule.md` to '1.0.0'

## PARAMETERS

### -HelpVersion
The help version number to use

```yaml
Type: SemanticVersion
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
