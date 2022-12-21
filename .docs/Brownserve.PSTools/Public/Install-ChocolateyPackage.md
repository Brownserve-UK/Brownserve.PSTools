---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Install-ChocolateyPackage

## SYNOPSIS
Helper cmdlet for installing Chocolatey packages programmatically

## SYNTAX

### default (Default)
```
Install-ChocolateyPackage [-PackageName] <String> [[-PackageVersion] <String>] [-Upgrade] [<CommonParameters>]
```

### pipeline
```
Install-ChocolateyPackage [-Upgrade] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet is intended to be used in automations to allow for easy installations of dependencies.
It's primary use case is for cloud based build agents that may not necessarily have all the required tooling available by default, though it can also be used to bulk install chocolatey packages on your local machine if you wish.
Given that Chocolatey is package manager for Windows this cmdlet is Windows Only.  

[Compatible with: Windows]

## EXAMPLES

### Example 1: Install a given package
```powershell
PS C:\> Install-ChocolateyPackage -PackageName 'awscli'
```

This would install the latest version of the `awscli` on the local system

### Example 2: Upgrade a package if it's already installed
```powershell
PS C:\> Install-ChocolateyPackage -PackageName 'awscli' -Upgrade
```

This would install the latest version of the `awscli` on the local system if it is not already installed, if it is installed but is not the latest version it will be updated

### Example 3: Bulk install packages
```powershell
PS C:\> @(
    [PSCustomObject]@{
        name = 'awscli'
        version = 'any'
    }],
    [PSCustomObject]@{
        Name = 'git'
        version = '1.0.0'
    }]
) | Install-ChocolateyPackages
```

This would install the latest version of the `awscli` on the local system and version `1.0.0` of git if they do not already exist

### Example 4: Passing in from a CSV
```powershell
PS C:\packages\> Import-CSV 'choco_packages.csv' | Install-ChocolateyPackages
```

Providing the csv file was structured correctly this would bulk install any packages from the CSV file.

## PARAMETERS

### -PackageName
The name of the chocolatey package to be installed

```yaml
Type: String
Parameter Sets: default
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PackageVersion
The version of the package to be installed, defaults to `any`

```yaml
Type: String
Parameter Sets: default
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Upgrade
If set will upgrade the package to the latest available version, providing a specific version has not been provided already.  
If used with pipeline input then this will upgrade **all** packages that are provided through the pipeline that do not have a specific version set.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### ChocolateyPackage[]
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
