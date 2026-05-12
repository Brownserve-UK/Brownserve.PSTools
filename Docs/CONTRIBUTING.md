# Contributing

Pull requests are welcome but please do bear in mind that these tools are designed specifically to work with Brownserve projects and are in use across various production CI/CD pipelines, therefore we may not be able to accommodate all requests.  

Code should be written following our [guidelines](./GUIDELINES.md) and should have complete documentation before being submitted (it will fail CI/CD if it doesn't).
Documentation will be generated for you when you run the `BuildWithDocs` task locally however some sections will be missing and will need to be completed manually.
For more information on how to build the module see the [build documentation](./BUILDING.md).

>**ℹ Please Note:**
Our branch protection rules **require** all commits to be [signed](https://docs.github.com/en/github/authenticating-to-github/managing-commit-signature-verification/signing-commits).  
While we can rebase and sign commits for you it's much more likely that your PR will be merged promptly if you ensure your commits are signed before submitting the PR.

We use the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) standard for PR titles and **this is a hard requirement.** Your PR title must begin with a recognised prefix so that an automated workflow can classify the change for the changelog. A second check will block merge if no valid label has been applied.

Supported prefixes (brackets are optional):

| Prefix examples | Type |
| --- | --- |
| `[feat]:` `feat:` `[feature]:` `feature:` | New feature or enhancement |
| `[fix]:` `fix:` `[bug]:` `bug:` | Bug fix |
| `[docs]:` `docs:` `[doc]:` `doc:` | Documentation update |
| `[ci]:` `ci:` `[cicd]:` `cicd:` | CI/CD changes |
| `[chore]:` `[refactor]:` `[ops]:` `[test]:` `[style]:` (and without brackets) | Maintenance |

Add `!` before the colon to flag a breaking change, e.g. `[feat!]: remove legacy parameter` or `fix!: rename cmdlet`.

>**ℹ Please Note:**
If your PR title does not match a recognised prefix the check will fail and a comment will be posted on the PR explaining what to fix. Simply update the title and the checks will re-run automatically.
