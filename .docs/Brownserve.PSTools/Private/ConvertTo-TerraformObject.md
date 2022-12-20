---
external help file: Brownserve.PSToolsPrivate-help.xml
Module Name: Brownserve.PSToolsPrivate
online version:
schema: 2.0.0
---

# ConvertTo-TerraformObject

## SYNOPSIS
Converts PowerShell objects into Terraform objects.

## SYNTAX

```
ConvertTo-TerraformObject [-Object] <Object> [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will take a String, Int, Array, Boolean or Hashtable and convert them into their respective Terraform objects.

## EXAMPLES

### Example 1: Converting a String
```powershell
PS C:\> ConvertTo-TerraformObject -Object "Hello, world"
```

This would return a quoted string `"Hello, world"`

### Example 1: Converting an Int
```powershell
PS C:\> ConvertTo-TerraformObject -Object 100
```

This would return `100`

### Example 1: Converting a Boolean
```powershell
PS C:\> ConvertTo-TerraformObject -Object $true
```

This would return `true`

### Example 1: Converting an Array
```powershell
PS C:\> ConvertTo-TerraformObject -Object @('a','b','c','d')
```

This would return `["a", "b", "c", "d"]`

### Example 1: Converting a Hashtable
```powershell
PS C:\> ConvertTo-TerraformObject -Object @{Foo = "Bar"}
```

This would return `{Foo = "bar"}`

## PARAMETERS

### -Object
The object to be converted

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Object

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
