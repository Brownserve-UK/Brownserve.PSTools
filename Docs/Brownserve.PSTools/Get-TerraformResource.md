---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Get-TerraformResource

## SYNOPSIS

Searches for and returns a given Terraform resource block.

## SYNTAX

```text
Get-TerraformResource [-ResourceType] <String> [-ResourceName] <String> [[-TerraformConfigPath] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

Searches a given directory or file for a terraform resource block matching the criteria specified.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-TerraformResource `
    -ResourceType 'github_team' `
    -ResourceName 'dashboard' `
```

This would search for the 'resource "github_team" "dashboard"' in the C:\terraform-github directory.

## PARAMETERS

### -ResourceName

The resource name

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

### -ResourceType

The resource type as defined in the Terraform modules documentation

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

### -TerraformConfigPath

Specifies a path to look for the resource block in.  
Can be a file or a directory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
