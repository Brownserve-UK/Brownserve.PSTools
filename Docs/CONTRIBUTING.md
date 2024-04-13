# Contributing

Pull requests are welcome but please do bear in mind that these tools are designed specifically to work with Brownserve projects and are in use across various production CI/CD pipelines, therefore we may not be able to accommodate all requests.  

Code should be written following our [guidelines](./GUIDELINES.md) and should have complete documentation before being submitted (it will fail CI/CD if it doesn't).
Documentation will be generated for you when you run the `BuildWithDocs` task locally however some sections will be missing and will need to be completed manually.
For more information on how to build the module see the [build documentation](./BUILDING.md).

>**ℹ Please Note:**
Our branch protection rules **require** all commits to be [signed](https://docs.github.com/en/github/authenticating-to-github/managing-commit-signature-verification/signing-commits).  
While we can rebase and sign commits for you it's much more likely that your PR will be merged promptly if you ensure your commits are signed before submitting the PR.

We also try to use the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) standard for our commit messages though this is not currently a hard requirement.
