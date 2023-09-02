---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Update-PlatyPSModulePageLinks

## SYNOPSIS
Updates the links to cmdlet documentation in the PlatyPS module page.

## SYNTAX

```
Update-PlatyPSModulePageLinks [-CmdletDocumentationPath] <String> [-ModulePagePath] <String>
 [<CommonParameters>]
```

## DESCRIPTION
When PlatyPS creates a module page the links it creates assume that the cmdlet documentation is in the same directory
as the module page.
This cmdlet will update the links to point to the correct location.
We may be able to remove the below once this issue is resolved: https://github.com/PowerShell/platyPS/issues/451

## EXAMPLES

### Example 1
```powershell
Update-PlatyPSModulePageLinks -CmdletDocumentationPath 'C:\MyModule\docs\en-US\Cmdlets' -ModulePagePath 'C:\MyModule\docs\en-US\MyModule.md'
```

This would update the links in the module page located at `C:\MyModule\docs\en-US\MyModule.md` to point to the cmdlet
documentation located at `C:\MyModule\docs\en-US\Cmdlets`

## PARAMETERS

### -CmdletDocumentationPath
The path to where the cmdlet documentation is stored

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
