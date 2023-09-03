# Performing a release
Releasing the module is done in two parts. First, the release is staged, then it is published.  
We do this to ensure the release has been reviewed by a human before it is published.

## Staging the release
To stage a release you'll need to run the `stage-release` GitHub action.
You'll to choose a [release type](#choosing-a-release-type) before the workflow will start.
The workflow will then create a new `release/v<version>` branch and on that branch it will determine the new version number, update the changelog with the changes/bugfixes/known issues since the last release, then finally update the module documentation version with the new version number.  
A pull request will then be created for the release, this will need to be reviewed and approved before the release can be published.  
If there's any issues with the changelog or documentation, you can make any adjustments necessary and push them to the branch that was created during the build.  
Once you're happy with the release, you can approve the pull request and merge it into the `main` branch, then you'll be able to publish the release.

## Publishing the release
Once the release has been staged, you can publish it by running the `publish-release` GitHub action.
This workflow will build and test the module, then all being will, publishes the module to the endpoints specified in the `$PublishTo` variable.

## Choosing a release type
When staging a release, you will be prompted to choose a release type, this will be used to determine the version number of the release.  
The release type can be one of the following:
* `major` - A major release, this will increment the major version number, and reset the minor and patch version numbers to 0.
* `minor` - A minor release, this will increment the minor version number, and reset the patch version number to 0.
* `patch` - A patch release, this will increment the patch version number.

### Major releases
Major releases are used for releases that contain breaking/non-backwards compatible changes.  
Some examples of breaking changes are:
* Substantially changing the behaviour of a cmdlet.
* Changing the output of a cmdlet such that it is no longer compatible with previous versions.
* Removing a previously deprecated cmdlet.
* Removing a previously deprecated input/output.
* Renaming a cmdlet/parameter/return value without first having followed the deprecation process.
* Fundamentally changing the return object of a cmdlet.

### Minor releases
Minor releases are used for releases that contain new features or backwards compatible changes.
Some examples of backwards compatible changes are:
* Adding a new cmdlet.
* Adding a new return value to a cmdlet without changing the existing return values.
* Adding a new parameter to a cmdlet without changing the existing ones.
* Renaming a parameter while providing an alias for the old name.
* Deprecating a cmdlet without removing it.
* Renaming a cmdlet while providing a deprecated copy with the old name.

### Patch releases
Patch releases are used for releases that contain bug fixes or other minor changes.
Some examples of patch changes are:
* Fixing a bug in a cmdlet while not changing the behaviour.
* Fixing typos.
* Documentation changes.
* CI/CD changes.
* Style/formatting changes that do not affect the behaviour of the cmdlet.

## Creating a Pre-release
Sometimes you may want to create a pre-release when you're moving between major versions or introducing sweeping changes to the module.  
To do this you'll need to create a new branch from the `main` branch and then run the `stage-release` GitHub action.  
This will detect that you're creating a release from a branch that isn't `main` and will create a pre-release instead of a full release.

## Re-publishing a previous release
Most of the endpoints we publish to will not allow you to re-publish a release with the same version number (for good reason!) so we actively check-for and prevent this from happening in the builds.
If there's an issue with a release that requires you to re-publish it, you'll need to increment the version number of the release and perform a new release. (If the issue is serious enough you should also pull the faulty release from the endpoints you've published to.)  

The only exception to this is when either adding a new release endpoint or when a push to an endpoint fails (for example if the endpoint is down at the time of publishing, or an API key is expired etc).
In these cases you can run the `publish-release` GitHub action again while giving the `PublishTo` variable only only the new/failed endpoint(s).
