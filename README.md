[![release Actions Status](https://github.com/Brownserve-UK/Brownserve.PSTools/workflows/release/badge.svg?branch=main)](https://github.com/Brownserve-UK/Brownserve.PSTools/actions)

# Brownserve.PSTools

A collection of PowerShell tools that are used across various Brownserve projects to aid in CI/CD deployments and give an easy to maintain common codebase.  
The tools are packaged as both a NuGet package and PSGallery PowerShell module for easy consumption across a wide variety of projects.

## What's included?

Please see the [module documentation](./Docs/Brownserve.PSTools.md) for a full list of cmdlets and their usage.

## How to use
>
>**ℹ Please Note:**
These tools have been designed for use within Brownserve projects and will likely have limited use outside of that.

If you'd like to have these tools available in your PowerShell session for you to use at leisure you can install the module from the PSGallery:

```powershell
Install-Module -Repository PSGallery -Name 'Brownserve.PSTools'
Import-Module 'Brownserve.PSTools'
```

If you're planning to use the module regularly then we'd recommend adding the import step to your [PowerShell Profile](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles).

If you'd like to use these tools within a repository (for example to perform builds or as part of CI/CD) then use the [`Initialize-BrownserveRepository`](./Docs/Brownserve.PSTools/Initialize-BrownserveRepository.md) and [`Update-BrownserveRepository`](./Docs/Brownserve.PSTools/Update-BrownserveRepository.md) cmdlets
