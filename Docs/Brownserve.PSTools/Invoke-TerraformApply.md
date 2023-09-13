---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Invoke-TerraformApply

## SYNOPSIS

Invokes 'terraform apply' with a given set of arguments

## SYNTAX

```text
Invoke-TerraformApply [[-TerraformConfigPath] <String>] [-TerraformPath <String>] [[-PlanFilePath] <String>]
 [[-Target] <String>] [-CompactWarnings <Boolean>] [-EnableColor <Boolean>] [[-Parallelism] <Int32>]
 [<CommonParameters>]
```

## DESCRIPTION

Invokes 'terraform apply' with a given set of arguments.
It can be run against a pre-existing plan or as a standalone pipeline, it is meant to be run from a CI/CD tool and as such offers no input.

## EXAMPLES

### EXAMPLE 1

```powershell
Invoke-TerraformApply
```

This would run a terraform apply against the current directory

## PARAMETERS

### -CompactWarnings

Whether or not to compact warning messages

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

### -EnableColor

Whether or not to enable color output, defaults to false so as not to break CI/CD tooling

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

### -Parallelism

Limit the number of concurrent operation as Terraform walks the graph.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PlanFilePath

A Terraform plan output object to be imported and used

```yaml
Type: String
Parameter Sets: (All)
Aliases: TerraformPlanPath

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Target

A resource to target (useful in testing).
Cannot be used when `PlanFilePath` is specified.

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

The path to the Terraform binary

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

### System.Int32

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
