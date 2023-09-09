---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# New-NuGetPackageVersion

## SYNOPSIS
*This cmdlet has been deprecated and will be removed in a future release, please use Format-NuGetPackageVersion instead*
Obtains a NuGet package version based on the build version number and branch name.

## SYNTAX

```
New-NuGetPackageVersion [-Version] <Version> [-BranchName] <String> [-Prerelease] [<CommonParameters>]
```

## DESCRIPTION
Obtains a NuGet package version based on a 3 or 4-digit build version number, the branch name and whether or not the branch is the default branch.

## EXAMPLES

### EXAMPLE 1: 4 digit number
```powershell
New-NuGetPackageVersion -Version '1.2.3.4' -BranchName 'main'
```

Would return '1.2.3.4'

### EXAMPLE 2: 4 digit number with pre-release suffix
```powershell
New-NuGetPackageVersion -Version '1.2.3.4' -BranchName 'SomeBranch' -Prerelease
```

Would return '1.2.3.4-SomeBranch'

### EXAMPLE 3: 3 digit number with pre-release suffix
```powershell
New-NuGetPackageVersion -Version '1.2.3' -BranchName 'SomeBranch' -Prerelease
```

Would return '1.2.3-SomeBranch.

## PARAMETERS

### -BranchName
The name of the current branch, this is used to suffix non production releases (eg feature releases etc)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Prerelease
If set this denotes that this version is a prerelease

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Version
A three or four digit version number of the form Major.Minor.Patch.Revision.

```yaml
Type: Version
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Version
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
