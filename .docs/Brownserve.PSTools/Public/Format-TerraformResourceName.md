---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Format-TerraformResourceName

## SYNOPSIS
Strips out illegal characters from Terraform resource names

## SYNTAX

```
Format-TerraformResourceName [-ResourceName] <String> [[-ValidCharacters] <String>] [<CommonParameters>]
```

## DESCRIPTION
Strips out illegal characters from Terraform resource names

## EXAMPLES

### EXAMPLE 1: String containing non-legal characters
```powershell
Format-ResourceName -ResourceName 'Illegal%%Resource_name'
```

This would return 'IllegalResource_name

### EXAMPLE 2: String starting with a digit
```powershell
Format-ResourceName -ResourceName '1llegal_Resource_name'
```

This would return 'N1llegal_Resource_name'

## PARAMETERS

### -ResourceName
The resource name to be formatted

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

### -ValidCharacters
The characters that are valid (takes the form of a RegEx pattern)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
