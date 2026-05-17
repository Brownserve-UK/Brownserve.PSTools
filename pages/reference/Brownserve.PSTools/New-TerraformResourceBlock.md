---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# New-TerraformResourceBlock

## SYNOPSIS

Creates a Terraform resource block that can easily be inserted into Terraform code.

## SYNTAX

```text
New-TerraformResourceBlock [-ResourceType] <String> [-ResourceName] <String> [-ResourceArgs] <PSObject>
 [<CommonParameters>]
```

## DESCRIPTION

This cmdlet is designed to make it easy to programmatically create Terraform resource blocks for insertion into Terraform configuration files.

## EXAMPLES

### Example 1: Simple resource

```powershell
PS C:\> New-TerraformResourceBlock `
    -ResourceType 'github_repository' `
    -ResourceName 'Brownserve_PSTools' `
    -ResourceArgs [PSCustomObject]@{
        Name = "Brownserve.PSTools"
        Visibility = "Public"
        Description = "Useful tools"
    }

resource "github_repository" "Brownserve_PSTools" {
    Name = "Brownserve.PSTools" 
    Visibility = "Public"
    Description = "Useful tools"
}
```

This example shows a fairly simple GitHub repository resource.

### Example 2: Complex resources

```powershell
PS C:\> New-TerraformResourceBlock `
    -ResourceType 'github_repository' `
    -ResourceName 'Brownserve_PSTools' `
    -ResourceArgs [PSCustomObject]@{
        Name = "Brownserve.PSTools"
        Visibility = "Public"
        Description = "Useful tools"
        Pages = @{
            Source = @{
                branch = "gh-pages"
                path = "/"
            }
            cname = "Foo.com"
        }
        topics = @('a','b')
        vulnerability_alerts = $true
    }

resource "github_repository" "Brownserve_PSTools" {
    Name = "Brownserve.PSTools"
    Visibility = "Public"
    Description = "Useful tools"
    Pages {   
        Source = {
            path = "/"
            branch = "gh-pages"
        }
        cname = "Foo.com"
    }
    topics = ["a", "b"]
    vulnerability_alerts  = true
}
```

This more advanced example includes a nested hashtable, an array and a boolean value.

### Example 3: Interpolation example

```powershell
PS C:\> New-TerraformResourceBlock `
    -ResourceType 'github_branch_default' `
    -ResourceName 'Brownserve_PSTools-Main' `
    -ResourceArgs [PSCustomObject]@{
        repository = "github_repository.Brownserve_PSTools.name"
        branch  = "var.default_branch"
    }

resource "github_repository" "Brownserve_PSTools" {
        repository = github_repository.Brownserve_PSTools.name
        branch = var.default_branch
}
```

In this example we are using another resource as the reference for our repository and a variable for the branch.
This cmdlet will automatically remove the quotes for these data sources to ensure they are compatible with Terraform.

## PARAMETERS

### -ResourceArgs

The arguments to be processed for this resource, these must be in the PSCustomObject format.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ResourceName

The name of the resource

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

The type of resource to be created

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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable, -ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.Management.Automation.PSObject

## OUTPUTS

### System.Object

## NOTES

Currently this cmdlet does not format nested maps very well.

## RELATED LINKS
