---
external help file: Brownserve.PSToolsPrivate-help.xml
Module Name: Brownserve.PSToolsPrivate
online version:
schema: 2.0.0
---

# Read-BrownserveInitFile

## SYNOPSIS
Reads an _init.ps1 file to extract certain information

## SYNTAX

```
Read-BrownserveInitFile [-InitFilePath] <String> [<CommonParameters>]
```

## DESCRIPTION
Reads an _init.ps1 file to extract certain information

## EXAMPLES

### Example 1
```powershell
PS C:\> Read-BrownserveInitFile c:\myRepo\_init.ps1
```

Would read the _init file at c:\myRepo\_init.ps1

## PARAMETERS

### -InitFilePath
The path to the _init.ps1 file

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
