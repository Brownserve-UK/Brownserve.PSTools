# GitHub Copilot Instructions

## Pull Request Titles

Always use [Conventional Commits](https://www.conventionalcommits.org/) format for PR titles:

```
<type>[optional scope]: <description>
```

### Types

- `feat` - a new feature
- `fix` - a bug fix
- `docs` - documentation changes only
- `style` - formatting, missing semicolons, etc. (no logic change)
- `refactor` - code change that is neither a fix nor a feature
- `test` - adding or updating tests
- `chore` - build process, dependency updates, tooling changes
- `ci` - changes to CI/CD configuration or workflows
- `perf` - performance improvements
- `revert` - reverts a previous commit

### Examples

```
feat(git): add support for shallow clones
feat: add new cmdlet for managing Azure resources
fix(common): resolve null reference in Merge-Hashtable
docs: update README with new build instructions
chore(deps): bump Pester to 5.6.0
ci: add workflow for labelling PRs
```

### Rules

- Use lowercase for the type and description
- Keep the description concise (50 characters or fewer where possible)
- Do not end the description with a period
- Use the imperative mood ("add support" not "added support")
- Include a scope in parentheses when the change is limited to a specific domain (e.g., `git`, `terraform`, `build`, `common`)
