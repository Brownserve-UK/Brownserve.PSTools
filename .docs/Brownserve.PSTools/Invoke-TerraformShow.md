---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Invoke-TerraformShow

## SYNOPSIS
Runs the `terraform show` command and converts the output into a PowerShell object.

## SYNTAX

```
Invoke-TerraformShow [[-TerraformConfigPath] <String>] [-TerraformPath <String>] [[-InputFile] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Runs the `terraform show` command and converts the output into a PowerShell object.
You can pass in the path to a Terraform plan output file or Terraform state file otherwise the command will just use the current state.

## EXAMPLES

### EXAMPLE 1: Using the current directory
```powershell
Invoke-TerraformShow
```

This would run 'terraform show' against the PWD's current state and convert the data into a PowerShell object.

### EXAMPLE 2: Using a plan file
```powershell
Invoke-TerraformShow -InputFile 'C:\terraform-github\plan.output'
```

This would run 'terraform show' against the saved plan at 'C:\terraform-github\plan.output' and convert the data into a PowerShell object.

## PARAMETERS

### -InputFile
An optional path to either a Terraform plan output file or Terraform state file, if none is provided the default state is used

```yaml
Type: String
Parameter Sets: (All)
Aliases: OutputPath, TerraformPlanPath, TerraformStatePath

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
