---
external help file: Brownserve.PSTools-help.xml
Module Name: Brownserve.PSTools
online version:
schema: 2.0.0
---

# Initialize-BrownserveBuildRepo

## SYNOPSIS
Prepares a repo to be able to consume and use the Brownserve.PSTools PowerShell module

## SYNTAX

```
Initialize-BrownserveBuildRepo [-RepoPath] <String> [-CustomInitSteps <String>] [-ExcludeModuleLoader]
 [-ExcludeSnippets] [-ExcludeVSCodeSettings] [-IncludeDevcontainer] [-Force] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet will assist in bootstrapping a repo for use with the Brownserve.PSTools PowerShellModule, it does so by:

* Setting up our standard directories, gitignore's and VSCode settings
* Configuring NuGet/paket
* Creating and _init.ps1 script to initialize the repo during builds

This cmdlet is experimental and hasn't yet been extensively tested, use with care.

## EXAMPLES

### Example 1
```powershell
PS C:\> Initialize-BrownserveBuildRepo -RepoPath C:\myRepo
```

This would prepare the repo at 'C:\myRepo' for use with Brownserve.BuildTools

## PARAMETERS

### -CustomInitSteps
If you know in advance any custom code you'd like to be included in the _init.ps1 script you can include it here.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeModuleLoader
If specified this will remove the code block that looks for custom PowerShell modules from the _init.ps1 script

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

### -ExcludeSnippets
If specified will skip copying our default VSCode snippets

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

### -ExcludeVSCodeSettings
If specified will skip copying our default VSCode settings

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

### -Force
If set will forcefully overwrite existing data, only use this if instructed to do so.

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

### -IncludeDevcontainer
If specified will copy over a basic devcontainer

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

### -RepoPath
The path to the repository to initialize

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
