# Building
We use [Invoke-Build](https://github.com/nightroman/Invoke-Build) to run our builds and [Pester](https://github.com/pester/Pester) to perform unit testing.
The build tasks are defined in the [build_tasks.ps1](../.build/tasks/build_tasks.ps1) script and the tests are located in the [tests](../.build/tests) directory.
There's a wrapper [build script](../.build/build.ps1) which is the entry point for all builds this takes care of initializing the build environment and calling the build tasks.

## Builds
The following build tasks are available:
* `Build` - Builds the module, imports it into the current session and then updates the module's documentation
* `BuildAndTest` - Performs the same tasks as `Build` but also runs the unit tests
* `BuildTestAndCheck` - Performs the same tasks as `BuildAndTest` but also ensures there are no uncommitted changes (this task is used in our CI/CD pipeline for pull requests)
* `StageRelease` - Stages a release (see [RELEASING](./RELEASING.md) for more information)
* `Release` - Releases the module to the configured repositories (see [RELEASING](./RELEASING.md) for more information)

For detailed information on each of the build tasks see the [build_tasks](../.build/tasks/build_tasks.ps1) script.

## How to build
To run a build it's as simple as calling `./.build/build.ps1 <task>` from the root of the repository.  
This will first initialize the build environment using the [`_init.ps1`](../.build/_init.ps1) script and then call the specified task using `Invoke-Build`.  

When developing your changes we recommended running the `Build` task often.  
This will:
* Build and import the module into your current session so you can test your changes easily
* Update/create the module documentation automatically
* Ensure that the line endings are set correctly for generated files (LF)

When you're ready to test your changes properly you can run the `BuildAndTest` task which will run the unit tests as well as the above tasks.

## Building locally
There are two ways to get all the dependencies you need to build locally, either using the included `.devcontainer` or manually installing them.
### .devcontainer
By far the easiest way to test things locally is to use the included `.devcontainer` within VS Code or other compatible IDE/editor.

This will spin up an environment with all the prerequisite dependencies installed and relaunch VS Code connected to that container.
This allows you to test things quickly and easily and avoid the potential to pollute your local system.  

This also has the benefit of including the VS Code extensions we use for linting, formatting and spelling so you can ensure your code is compliant with our guidelines.

### Manual installation
If you don't use VSCode or want to build manually for whatever reason you will need to ensure you have:
* [dotnet](https://dotnet.microsoft.com/download) installed and available on your path
* [PowerShell Core](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.1) installed and available on your path
* If on a *nix system you'll also need [mono](https://www.mono-project.com/download/stable/) to be able to run NuGet.exe

## CI/CD
### GitHub Actions
Currently we use GitHub Actions to build and test the module on every PR to the `main` branch.  
The GitHub Actions workflow will run the `BuildTestAndCheck` task which will build the module, run the unit tests and then check for any uncommitted changes.  
This ensures that any changes to the module are thoroughly tested and that the documentation is fully up to date before merging.
There are also two release related workflows which can be manually triggered to stage and release a new version of the module (for more information see [RELEASING](./RELEASING.md)).
