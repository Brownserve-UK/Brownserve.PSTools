[![release Actions Status](https://github.com/Brownserve-UK/Brownserve.PSTools/workflows/release/badge.svg?branch=main)](https://github.com/Brownserve-UK/Brownserve.PSTools/actions)
# Brownserve.PSTools
A collection of PowerShell tools that are used across various Brownserve projects to aid in CI/CD deployments and give an easy to maintain common codebase.  
The tools are packaged as both a NuGet package and PSGallery PowerShell module for easy consumption across a wide variety of projects.
## What's included?
Please see the [module documentation](./Docs/Brownserve.PSTools.md) for a full list of cmdlets and their usage.

## How to use
>**ℹ Please Note**    
These tools have been designed for use within Brownserve projects and may have limited use outside of that.  

If you simply want to have these tools available in your PowerShell session you can install the module from the PSGallery using `Install-Module -Name Brownserve.PSTools`.  
To use these within a project you can use the [`Initialize-BrownserveRepository`](./Docs/Brownserve.PSTools/Initialize-BrownserveRepository.md) cmdlet which will initialize the repository with the required files and settings.

## Contributing
Pull requests are welcome but please do bear in mind that these tools are designed specifically to work with Brownserve projects and are in use across various production CI/CD pipelines, therefore we may not be able to accommodate all requests.  

Code should be written following our [guidelines](./Docs/GUIDELINES.md) and should have complete documentation before being submitted (it will fail CI/CD if it doesn't).
Documentation will be generated for you when you run the `Build` task locally however some sections will be missing and will need to be completed manually.
For more information on how to build the module see the [build documentation](./Docs/BUILDING.md).

>**ℹ Please Note**    
Our branch protection rules **require** all commits to be [signed](https://docs.github.com/en/github/authenticating-to-github/managing-commit-signature-verification/signing-commits).  
While we can rebase and sign commits for you it's much more likely that your PR will be merged promptly if you ensure your commits are signed before submitting the PR.

We also try to use the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) standard for our commit messages though this is not currently a hard requirement.
