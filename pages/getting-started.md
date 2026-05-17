# Getting Started

!!! note
    These tools have been designed for use within Brownserve projects and will likely have limited use outside of that.

## Prerequisites

This module requires **PowerShell 6.0 or later**. You can download it from the [official PowerShell repository](https://github.com/PowerShell/PowerShell/releases).

## Installing the module

To make the module available in your PowerShell session, install it from the PSGallery:

```powershell
Install-Module -Repository PSGallery -Name 'Brownserve.PSTools'
Import-Module 'Brownserve.PSTools'
```

If you plan to use the module regularly, add the import step to your [PowerShell Profile](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles).

## Using the module in a repository

To use these tools within a repository (for example to perform builds or as part of CI/CD), use the
[`Initialize-BrownserveRepository`](reference/Brownserve.PSTools/Initialize-BrownserveRepository.md)
cmdlet to set up a new repository, or
[`Update-BrownserveRepository`](reference/Brownserve.PSTools/Update-BrownserveRepository.md)
to bring an existing repository up to date.
