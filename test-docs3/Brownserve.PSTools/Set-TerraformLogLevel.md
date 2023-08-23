---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version: https://api.slack.com/messaging/composing/layouts
schema: 2.0.0
---

# Set-TerraformLogLevel

## SYNOPSIS
Provides an easy way to set the Terraform log level.

## SYNTAX

```
Set-TerraformLogLevel [[-LogLevel] <String>] [<CommonParameters>]
```

## DESCRIPTION
Provides an easy way to set the Terraform log level.
Valid options are:     * DEBUG     * TRACE     * INFO     * WARN     * none The default value is "none"

## EXAMPLES

### EXAMPLE 1: Set Terraform's log level to DEBUG
```
Set-TerraformLogLevel -LogLevel 'DEBUG'
```

Would set the Terraform log level to DEBUG

### EXAMPLE 2: Set Terraform's log level to WARN
```
Set-TerraformLogLevel -LogLevel 'WARN'
```

Would set the Terraform log level to WARN

### EXAMPLE 3: Set Terraform's log level to none
```
Set-TerraformLogLevel -LogLevel 'none'
```

Would set the Terraform log level to none

## PARAMETERS

### -LogLevel
The log level to set

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: DEBUG, TRACE, INFO, WARN, ERROR, none

Required: False
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
