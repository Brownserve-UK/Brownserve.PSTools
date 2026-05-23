# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Release

## [v0.19.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.19.0) (2026-05-23)

### Breaking Changes

- refactor!: remove TeamCity, Vault, Terraform cmdlets in [#182](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/182) by [@shoddyguard](https://github.com/shoddyguard)
- refactor!: remove deprecated GitHub cmdlets in [#169](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/169) by [@shoddyguard](https://github.com/shoddyguard)
- refactor!: remove `New-NuGetPackageVersion` in [#167](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/167) by [@shoddyguard](https://github.com/shoddyguard)
- refactor!: remove `New-ChangelogBlock` in [#166](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/166) by [@shoddyguard](https://github.com/shoddyguard)
- refactor!: remove `Read-Changelog` and `Search-FileContent` in [#168](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/168) by [@shoddyguard](https://github.com/shoddyguard)

### Added

- feat: ensure new changelogs get our standard header by default in [#179](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/179) by [@shoddyguard](https://github.com/shoddyguard)

### Fixed

- fix: remove unused ReleaseNotice logic in [#181](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/181) by [@shoddyguard](https://github.com/shoddyguard)
- fix(ci): make check case insensitive in [#180](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/180) by [@shoddyguard](https://github.com/shoddyguard)
- docs: update changelog header to mention `keep a changelog` in [#176](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/176) by [@shoddyguard](https://github.com/shoddyguard)
- fix(templates): update repo templates in [#175](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/175) by [@shoddyguard](https://github.com/shoddyguard)
- docs: switch mkdocs from using tabs to sidebar nav in [#174](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/174) by [@shoddyguard](https://github.com/shoddyguard)
- fix: PR title interpolation in [#173](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/173) by [@shoddyguard](https://github.com/shoddyguard)
- fix: make the module tests actually useful in [#171](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/171) by [@shoddyguard](https://github.com/shoddyguard)

### Changed

- refactor: remove unused private cmdlets in [#172](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/172) by [@shoddyguard](https://github.com/shoddyguard)


## [v0.18.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.18.0) (2026-05-18)

### Added

- feat: add pester test templates for documentation in [#163](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/163) by [@shoddyguard](https://github.com/shoddyguard)

### Fixed

- fix: ensure New-BrownservePowerShellModule sets directory in [#162](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/162) by [@shoddyguard](https://github.com/shoddyguard)
- fix: ensure unique file paths and create ModuleInfo.json in [#161](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/161) by [@shoddyguard](https://github.com/shoddyguard)
- docs: refactor documentation for clarity and accessibility in [#160](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/160) by [@shoddyguard](https://github.com/shoddyguard)

### Deprecated

- deprecated: deprecate several unused cmdlets in [#164](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/164) by [@shoddyguard](https://github.com/shoddyguard)


## [v0.17.1](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.17.1) (2026-05-17)

### Added

- feat: add mkdocs generation templates to Initialize-BrownserveRepository in [#158](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/158) by [@shoddyguard](https://github.com/shoddyguard)

### Fixed

- docs: move module documentation over to using mkdocs in [#156](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/156) by [@shoddyguard](https://github.com/shoddyguard)
- docs: refactor repo documentation in [#155](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/155) by [@shoddyguard](https://github.com/shoddyguard)
- fix: module help version updater in [#153](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/153) by [@shoddyguard](https://github.com/shoddyguard)


## [v0.17.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.17.0) (2026-05-13)

_Going forward this Changelog will use the "Keep a Changelog" format_

### Features

These are the changes that have been made since v0.16.1:

- [cicd]: fix missing logic for release notes in [#150](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/150) by [@shoddyguard](https://github.com/shoddyguard)
- [ops]: fix codeowners casing in [#149](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/149) by [@shoddyguard](https://github.com/shoddyguard)
- [ops]: add repo CODEOWNERS in [#148](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/148) by [@shoddyguard](https://github.com/shoddyguard)
- [chore]: update GHA templates to match new standard in [#147](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/147) by [@shoddyguard](https://github.com/shoddyguard)
- [sec]: improve security of GitHub Actions workflows in [#146](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/146) by [@shoddyguard](https://github.com/shoddyguard)
- [sec]: ensure GitHub Token used for PR builds is `readonly` in [#145](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/145) by [@shoddyguard](https://github.com/shoddyguard)
- [docs]: add instructions on how to handle changes to build scripts in [#144](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/144) by [@shoddyguard](https://github.com/shoddyguard)
- [chore]: update repo to latest standard in [#143](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/143) by [@shoddyguard](https://github.com/shoddyguard)
- [fix]: undo changes to `Compare-BrownserveRepository` in [#142](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/142) by [@shoddyguard](https://github.com/shoddyguard)
- [cicd]: update release workflows with `UseWorkingCopy` flag in [#140](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/140) by [@shoddyguard](https://github.com/shoddyguard)
- [feat]: update repo templates for PowerShell modules in [#138](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/138) by [@shoddyguard](https://github.com/shoddyguard)
- [build]: Bump paket from 8.0.3 to 10.3.1 in [#137](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/137) by [@dependabot[bot]](https://github.com/apps/dependabot)
- [cicd]: bump actions/create-github-app-token from 1 to 3 in [#135](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/135) by [@dependabot[bot]](https://github.com/apps/dependabot)
- [cicd]: bump actions/checkout from 3 to 6 in [#134](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/134) by [@dependabot[bot]](https://github.com/apps/dependabot)
- [cicd]: bump actions/github-script from 7 to 9 in [#136](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/136) by [@dependabot[bot]](https://github.com/apps/dependabot)
- [cicd]: enable dependabot for this repo in [#133](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/133) by [@shoddyguard](https://github.com/shoddyguard)
- [feat]: add dependabot to our PowerShell repos in [#132](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/132) by [@shoddyguard](https://github.com/shoddyguard)
- [cicd]: enable `UseWorkingCopy` for stage-release in [#130](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/130) by [@shoddyguard](https://github.com/shoddyguard)
- [style!]: make auto-changelog entries follow the "Keep a Changelog" format in [#128](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/128) by [@shoddyguard](https://github.com/shoddyguard)
- [cicd]: update the auto labeller to include the new labels in [#127](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/127) by [@shoddyguard](https://github.com/shoddyguard)
- [docs]: updating the contributing guide to cover new PR format in [#124](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/124) by [@shoddyguard](https://github.com/shoddyguard)
- [cicd]: Attempt to fix the PR labeller in [#122](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/122) by [@shoddyguard](https://github.com/shoddyguard)
- [cicd]: add new workflow to validate pr's are in correct format in [#119](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/119) by [@shoddyguard](https://github.com/shoddyguard)
- cicd: cleanup build notifications. in [#117](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/117) by [@shoddyguard](https://github.com/shoddyguard)
- fix: NuGet license warning in [#116](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/116) by [@shoddyguard](https://github.com/shoddyguard)
- ops: remove use of -UseWorkingCopy in [#115](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/115) by [@shoddyguard](https://github.com/shoddyguard)
- ops: remove snippet-creator in [#114](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/114) by [@shoddyguard](https://github.com/shoddyguard)
- chore: update repo to latest standard in [#113](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/113) by [@shoddyguard](https://github.com/shoddyguard)
- fix: dotnet tool temp location in [#112](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/112) by [@shoddyguard](https://github.com/shoddyguard)
- feat: update repo templating in [#111](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/111) by [@shoddyguard](https://github.com/shoddyguard)
- feat: move GitHub Actions builds to templates in [#110](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/110) by [@shoddyguard](https://github.com/shoddyguard)
- fix: update init templates in [#109](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/109) by [@shoddyguard](https://github.com/shoddyguard)
- docs: cleanup changelog in [#107](https://github.com/Brownserve-UK/Brownserve.PSTools/pull/107) by [@shoddyguard](https://github.com/shoddyguard)

### Bugfixes

The following bugs have been closed since v0.16.1:

- [#78](https://github.com/Brownserve-UK/Brownserve.PSTools/issues/78) - [BUG]: Snippet Creator is deprecated

### Known Issues

The following bugs have been raised since v0.16.1 and remain unresolved:

- *N/A*

For a full list of current known issues see the project's [issues page](https://github.com/Brownserve-UK/Brownserve.PSTools/issues).

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
