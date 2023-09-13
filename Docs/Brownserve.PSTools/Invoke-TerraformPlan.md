---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Invoke-TerraformPlan

## SYNOPSIS

Invokes a Terraform plan with a selection of given parameters

## SYNTAX

```text
Invoke-TerraformPlan [[-TerraformConfigPath] <String>] [-TerraformPath <String>] [[-OutputPath] <String>]
 [[-Target] <String>] [-Refresh <Boolean>] [-DetailedExitCodes <Boolean>] [-Parallelism <Int32>]
 [-EnableColor <Boolean>] [<CommonParameters>]
```

## DESCRIPTION

Invokes a Terraform plan with a selection of given parameters, this is designed for CI/CD deployments and is non-interactive.

## EXAMPLES

### EXAMPLE 1: Specify the path to Terraform

```powershell
Invoke-TerraformPlan -TerraformPath C:\Tools\Terraform.exe
```

Will run a terraform plan against the current directory using C:\Tools\Terraform.exe

### EXAMPLE 2: Specify a plan output folder

```powershell
Invoke-TerraformPlan -OutputPath C:\Tools\terraform.plan
```

Will run a terraform plan against the current directory using whatever Terraform command is in your path and export the plan results to C:\Tools\terraform.plan

## PARAMETERS

### -DetailedExitCodes

Whether or not to use detailed exit codes (defaults to false)

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

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

### -OutputPath

The path to store the output of the Terraform plan

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Parallelism

Limit the number of concurrent operation as Terraform walks the graph.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Refresh

Whether or not to refresh resources

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Target

A resource to target (useful in testing)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
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
Default value: PWD
Accept pipeline input: True (ByPropertyName)
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
