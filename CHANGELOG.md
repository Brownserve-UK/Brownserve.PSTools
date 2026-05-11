# Changelog

All notable changes to this project will be documented in this file.
This project conforms to the [SemVer v2.0.0 spec](https://semver.org/spec/v2.0.0.html)

## Release

## [v0.16.1](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.16.1) (2026-05-11)

### Features

These are the changes that have been made since v0.15.0:

- fix: don't try to publish preview packages when a stable package exists. in [#105](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/105) by [@shoddyguard](https://github.com/shoddyguard)
- fix: revert using .NET nuget in [#104](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/104) by [@shoddyguard](https://github.com/shoddyguard)
- fix: remove references to Mono - nuget is available on Linux now in [#103](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/103) by [@shoddyguard](https://github.com/shoddyguard)
- cicd: switch over to using the app token rather than a user token. in [#102](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/102) by [@shoddyguard](https://github.com/shoddyguard)
- fix: broken nuget build logic in [#101](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/101) by [@shoddyguard](https://github.com/shoddyguard)
- Prepare for v0.16.0-preview2 in [#100](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/100) by [@brownserve-ci-cd[bot]](https://github.com/apps/brownserve-ci-cd)
- fix: ensure changelog release notes are generated correctly. in [#97](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/97) by [@shoddyguard](https://github.com/shoddyguard)
- cicd: Move staging build over to using new GitHub App to avoid using PAT/GPG keys in [#92](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/92) by [@shoddyguard](https://github.com/shoddyguard)
- fix: don't throw when we can't find a merge commit in [#94](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/94) by [@shoddyguard](https://github.com/shoddyguard)
- fix: remove references to UpdateModulePageHelpVersion, we don't use this method anymore. in [#93](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/93) by [@shoddyguard](https://github.com/shoddyguard)
- feat: add new cmdlets for creating remote branches and commits via the GitHub API. in [#91](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/91) by [@shoddyguard](https://github.com/shoddyguard)
- feat: add temp location logic to `New-BrownservePowerShellModule` in [#90](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/90) by [@shoddyguard](https://github.com/shoddyguard)
- check dotnet has at least one SDK installed so `dotnet new` will work in [#88](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/88) by [@shoddyguard](https://github.com/shoddyguard)
- ops: update Slack webhook build secret name in [#89](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/89) by [@shoddyguard](https://github.com/shoddyguard)
- Overhaul of the `Initialize-BrownserveRepository` and `Update-BrownserveRepository` cmdlets in [#87](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/87) by [@shoddyguard](https://github.com/shoddyguard)
- Set standard location for user configs. in [#86](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/86) by [@shoddyguard](https://github.com/shoddyguard)
- Fix generated docs to keep them consistent in [#83](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/83) by [@shoddyguard](https://github.com/shoddyguard)
- Standardise GitHub cmdlet styling in [#82](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/82) by [@shoddyguard](https://github.com/shoddyguard)
- Add Add-GitHubReleaseAsset cmdlet in [#81](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/81) by [@shoddyguard](https://github.com/shoddyguard)
- Prepare for v0.16.0-preview in [#77](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/77) by [@brownserve-automatedbuild](https://github.com/brownserve-automatedbuild)
- Bring in Dev changes in [#74](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/74) by [@shoddyguard](https://github.com/shoddyguard)
- Documentation Overhaul in [#61](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/61) by [@shoddyguard](https://github.com/shoddyguard)
- Rework PowerShell-YAML logic in [#60](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/60) by [@shoddyguard](https://github.com/shoddyguard)
- feat: Add Get-GitHubPullRequests in [#59](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/59) by [@shoddyguard](https://github.com/shoddyguard)

### Bugfixes

The following bugs have been closed since v0.15.0:

- *N/A*

### Known Issues

The following bugs have been raised since v0.15.0 and remain unresolved:

- [#78](https://github.com/Brownserve-UK/Brownserve.PSTools/issues/78) - [BUG]: Snippet Creator is deprecated

For a full list of current known issues see the project's [issues page](https://github.com/Brownserve-UK/Brownserve.PSTools/issues).

## [v0.16.1-preview1](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.16.1-preview1) (2026-05-11)

### Features

These are the changes that have been made since v0.15.0:

- fix: ensure changelog release notes are generated correctly. in [#97](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/97) by [@shoddyguard](https://github.com/shoddyguard)
- cicd: Move staging build over to using new GitHub App to avoid using PAT/GPG keys in [#92](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/92) by [@shoddyguard](https://github.com/shoddyguard)
- fix: don't throw when we can't find a merge commit in [#94](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/94) by [@shoddyguard](https://github.com/shoddyguard)
- fix: remove references to UpdateModulePageHelpVersion, we don't use this method anymore. in [#93](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/93) by [@shoddyguard](https://github.com/shoddyguard)
- feat: add new cmdlets for creating remote branches and commits via the GitHub API. in [#91](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/91) by [@shoddyguard](https://github.com/shoddyguard)
- feat: add temp location logic to `New-BrownservePowerShellModule` in [#90](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/90) by [@shoddyguard](https://github.com/shoddyguard)
- check dotnet has at least one SDK installed so `dotnet new` will work in [#88](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/88) by [@shoddyguard](https://github.com/shoddyguard)
- ops: update Slack webhook build secret name in [#89](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/89) by [@shoddyguard](https://github.com/shoddyguard)
- Overhaul of the `Initialize-BrownserveRepository` and `Update-BrownserveRepository` cmdlets in [#87](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/87) by [@shoddyguard](https://github.com/shoddyguard)
- Set standard location for user configs. in [#86](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/86) by [@shoddyguard](https://github.com/shoddyguard)
- Fix generated docs to keep them consistent in [#83](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/83) by [@shoddyguard](https://github.com/shoddyguard)
- Standardise GitHub cmdlet styling in [#82](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/82) by [@shoddyguard](https://github.com/shoddyguard)
- Add Add-GitHubReleaseAsset cmdlet in [#81](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/81) by [@shoddyguard](https://github.com/shoddyguard)
- Prepare for v0.16.0-preview in [#77](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/77) by [@brownserve-automatedbuild](https://github.com/brownserve-automatedbuild)
- Bring in Dev changes in [#74](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/74) by [@shoddyguard](https://github.com/shoddyguard)
- Documentation Overhaul in [#61](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/61) by [@shoddyguard](https://github.com/shoddyguard)
- Rework PowerShell-YAML logic in [#60](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/60) by [@shoddyguard](https://github.com/shoddyguard)
- feat: Add Get-GitHubPullRequests in [#59](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/59) by [@shoddyguard](https://github.com/shoddyguard)

### Bugfixes

The following bugs have been closed since v0.15.0:

- *N/A*

### Known Issues

The following bugs have been raised since v0.15.0 and remain unresolved:

- [#78](https://github.com/Brownserve-UK/Brownserve.PSTools/issues/78) - [BUG]: Snippet Creator is deprecated

For a full list of current known issues see the project's [issues page](https://github.com/Brownserve-UK/Brownserve.PSTools/issues).
