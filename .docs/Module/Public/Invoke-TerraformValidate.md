---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Invoke-TerraformValidate

## SYNOPSIS
Performs a 'terraform validate'

## SYNTAX

```
Invoke-TerraformValidate [[-TerraformConfigPath] <String>] [-TerraformPath <String>] [-EnableColor <Boolean>]
 [<CommonParameters>]
```

## DESCRIPTION
Performs a 'terraform validate'

## EXAMPLES

### EXAMPLE 1
```powershell
Invoke-TerraformValidate
```

Would validate the Terraform configuration in the present directory

## PARAMETERS

### -EnableColor
Whether or not to enable color output, defaults to false so as not to break CI/CD tools

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TerraformConfigPath
Path to the Terraform configuration files (defaults to current working directory)

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

### -TerraformPath
The Path to the Terraform binary

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: terraform
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### System.Boolean
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
