# Contributing
Pull requests are welcome but please do bear in mind that these tools are designed specifically to work in our projects and are used in production CI/CD pipelines, therefore we may not be able to accommodate all requests.  

If you still wish to contribute then read on!

## Update the module
New cmdlets/functions need to be added to the `./Module` directory, under either the `Public` or `Private` sub directory.  
`Public` is used to store code that should be accessible outside the module (e.g. after an `Import-Module`) whereas `Private` is used to store code that is **only** used _within_ the module itself.  
For general tips on writing code for this repo take a look at our [guidelines](GUIDELINES.md).

>**DO NOT INCLUDE COMMENT-BASED HELP DOCUMENTATION IN PUBLIC CODE**  
This is because it will conflict with the MAML based help that we use in this module, see [Update the help files](#update-help-files) for more information.

## Update help files
Our public cmdlets/functions **must** have help documentation, it's a requirement to build the module successfully.  
We use [platyPS](https://github.com/PowerShell/platyPS) (the same tool Microsoft use) to help generate our help documentation.  
This allows us to create Markdown based help files in the `.docs` directory which are much easier to read for us humans, then have platyPS generate the module's XML MAML documentation from these Markdown files.

Our `_init.ps1` script contains some helper functions for creating/updating documentation:
```powershell
Update-Documentation
Update-ModuleHelp
```
The first function will create/update all the Markdown help in the `.docs/Module` directory and the second will update the module's XML MAML help file.

See the example below for a guide on how to use these.

## Update the changelog  
The changelog _must_ be updated when making a release, this is because the changelog is used to calculate the NuGet package manifest/version number and release notes.   
The changelog follows the [SemVer v1.0.0](https://semver.org/spec/v1.0.0.html) spec.  
You can use the [`Update-Changelog`](.docs/Module/Public/Update-Changelog.md) cmdlet from this very module to make the changes for you, the cmdlet is fully guided and it will even offer to auto-generate the changelog entries based off of a list of commits since the last release. 🪄🧙‍♂️

## Example
Let's say we want to create a new cmdlet called `New-Cmdlet` and add it to the Brownserve.PSTools module, this cmdlet will in turn call `New-PrivateCmdlet` for some logic.  
For this example we'll assume the current release is `v0.1.0`  and that our repo is in the `C:\MyRepos\Brownserve.PSTools` directory.  
We'll also assume our cmdlet has something to do with `GitHub`

First let's create a new cmdlet in `C:\MyRepos\Brownserve.PSTools\Module\Public\GitHub` called `New-Cmdlet.ps1` with the following content:
```powershell
function New-Cmdlet
{
    [CmdletBinding()]
    param
    (
        # Your name
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [string]
        $Name
    )
    Write-Host "Hello $Name"
    New-PrivateCmdlet
}
```

Now let's create it's counterpart in `C:\MyRepos\Brownserve.PSTools\Module\Private\GitHub` called `New-PrivateCmdlet.ps1`:
```powershell
function New-PrivateCmdlet
{
    [CmdletBinding()]
    param
    ()
    Write-Host "I am a private cmdlet"
}

```

Let's test our cmdlet's to make sure they work:
```powershell
# First import our module
Import-Module ./Module/Brownserve.PSTools.psm1
# Now run our cmdlet
New-Cmdlet -Name 'Steve'
```
We should see:
```
Hello Steve
I am a private cmdlet
```
If we try to run our private cmdlet we should get:
```
New-PrivateCmdlet: The term 'New-PrivateCmdlet' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
```

Next let's update the help files, to do this we'll need to run `_init_.ps1`
```powershell
./.build/_init.ps1
```

Now we can create our Markdown help documentation for our new cmdlet's with:
```powershell
Update-Documentation
```
Providing that worked correctly you should see the following:
```
Updating Brownserve.PSTools documentation…
Updating 'Public' Markdown documentation…
Updating 'Private' Markdown documentation...
Markdown help has been successfully updated!
```

Once that's done we'll need to head over to the `./.docs/Module` directory and edit any data that's missing from the help files, this will be denoted by double curly braces `{{ }}`
More info on the platyPS schema can be found [here](https://github.com/PowerShell/platyPS/blob/master/platyPS.schema.md)  
As a quick example our `New-Cmdlet.md` file's synopsis would go from this:
```markdown
# New-Cmdlet

## SYNOPSIS
{{ Fill in the Synopsis }}

```
To this:
```markdown
# New-Cmdlet

## SYNOPSIS
This cmdlet is for demonstration purposes only
```

Once all this information is filled in you will then need to update the modules XML help, simply run the following:
```powershell
Update-ModuleHelp
```

You should see the following:
```
Generating module help from Markdown files...
Module XML help successfully updated!
```

Finally we need to update the changelog file, we can do this using a cmdlet from the Brownserve.PSTools module:
```powershell
Update-Changelog `
    -ChangelogPath ./CHANGELOG.md `
    -ReleaseType 'minor' `
    -Features 'Added New-Cmdlet cmdlet'
    -SkipOptionalPrompts
```
Which should result in the following changelog file:
```markdown
# Changelog

All notable changes to this project will be documented in this file.
This changelog follows the [SemVer v1.0.0 spec](https://semver.org/spec/v1.0.0.html)

## Release 

### [v0.2.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.2.0) (2021-09-16)

**Features**
- Added New-Cmdlet cmdlet
  
**Bugfixes**
None

**Known Issues**
None

### [v0.1.0](https://github.com/Brownserve-UK/Brownserve.PSTools/tree/v0.1.0) (2021-09-16)

**Features**
- First release of the module!
  
**Bugfixes**
None

**Known Issues**
None

```

With that done, you should be good to build, test and ship a new release! 😎