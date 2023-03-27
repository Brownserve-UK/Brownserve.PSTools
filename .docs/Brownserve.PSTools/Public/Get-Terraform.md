---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Get-Terraform

## SYNOPSIS
Downloads the given version of Terraform for your OS

## SYNTAX

```
Get-Terraform [[-TerraformVersion] <Version>] [-DownloadPath] <String> [<CommonParameters>]
```

## DESCRIPTION
This cmdlet downloads the specified version of Terraform to the a given directory.  
This allows us to use different versions of Terraform across different repositories easily (though the cmdlet could be used to download Terraform to your system if desired).  
This cmdlet should work across Windows, macOS and Linux.  

The command `terraform` is replaced by an alias to the downloaded binary and the `$env:TerraformPath` variable is set pointing to the downloaded version of Terraform, this only affects your current PowerShell session.

## EXAMPLES

### EXAMPLE 1: Download the default version
```powershell
Get-Terraform -DownloadPath 'C:\tools'
```

Will download Terraform to C:\tools  
An Alias for the `terraform` command would be created and the `$env:TerraformPath` variable would be set pointing to this version for your current PowerShell session.

### EXAMPLE 2: Pass in a version number
```powershell
Get-Terraform -TerraformVersion '1.0.0' -DownloadPath 'C:\tools'
```

Will download Terraform v1.0.0 to C:\tools  
An Alias for the `terraform` command would be created and the `$env:TerraformPath` variable would be set pointing to this version for your current PowerShell session.

## PARAMETERS

### -DownloadPath
The path to download the binary to

```yaml
Type: String
Parameter Sets: (All)
Aliases: path

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TerraformVersion
The version of Terraform to download

```yaml
Type: Version
Parameter Sets: (All)
Aliases:

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
$env:TerraformPath will be set upon successful download/extraction and the command 'terraform' will be set to this
downloaded version of terraform for this session.

## RELATED LINKS
