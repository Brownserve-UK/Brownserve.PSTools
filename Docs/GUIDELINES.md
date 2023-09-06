# Guidelines
## Writing cmdlets

### Don't construct paths manually
Don't form paths by passing in separators (e.g. `C:\`, `/usr/`), use the tools PowerShell gives you:

* [`Resolve-Path`](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/resolve-path?view=powershell-7.1) can be used to validate user submitted paths or resolve the path to commands/aliases.
* [`Join-Path`](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/join-path?view=powershell-7.1) can be used to construct paths _(top tip: you can specify multiple values in_ `-AdditionalChildPaths`)
* [`Convert-Path`](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/convert-path?view=powershell-7.1) by default PowerShell stores paths as a `PSPath` which can break environment variables, Convert-Path converts a `PSPath` to the standard path format for your OS.
  
All these cmdlets will handle the path separators for you and will ensure that the path is valid for the current operating system.  
By using these you give your code a much higher chance of working across different operating systems. 😊

### OS specific cmdlets
By default we treat all cmdlets as cross-platform but there may be instances where your code will only work on certain operating systems (e.g. `Install-ChocolateyPackage`), in these cases you should call `Test-OperatingSystem` at the beginning of your cmdlet with the supported OSes as the first (and only) parameter.  
If the current OS isn't in the supported list then an exception will be raised.  

**Example:**  
In this example we're running on a Linux based operating system so the cmdlet will run successfully:
```powershell
> $isLinux
> $True
> Test-OperatingSystem 'Linux','macOS' -Verbose
> VERBOSE: This cmdlet is supported on Linux
```
Moving over to a Windows based operating system we can see that the cmdlet will now throw an exception:
```powershell
> $isWindows
> $True
> Test-OperatingSystem 'Linux','macOS' -Verbose
> Exception: This cmdlet is not compatible with Windows
```

### Use `Start`, `Process` and `End` blocks
Even if your cmdlet doesn't support pipeline input you should still use the `Start`, `Process` and `End` blocks.  
This allows us to easily add support for pipeline input in the future and keeps the code consistent.

### Define parameter properties
When defining parameters you should always define the parameter properties, including the `Mandatory`, `Position` and `ValueFromPipelineByPropertyName` properties where applicable.

### Define parameter types
When defining parameters you should always define the parameter type, this allows PowerShell to validate the input and provide tab completion.

### Ensure parameter names are consistent
When defining parameters you should ensure that the parameter names are consistent across all cmdlets, for example if you have a parameter called `Token` in one cmdlet then you should use `Token` in all cmdlets, not `PAT` or `AccessToken` etc.


## Writing Documentation

### All `Public` cmdlets **must** have documentation
All `Public` cmdlets **must** have documentation, and all documentation **must** be complete (this will fail CI/CD if it isn't).  
Running any of the build tasks will automatically generate the documentation for you, however some sections will be missing and will need to be completed manually. These will be surrounded by `{{ }}` to make them easy to find (e.g. `{{ Fill in Synopsis }}`).  
There are some tests as part of the `BuildAndTest` task will check for incomplete sections and highlight them in the build output.

### Documentation must use LF line endings
Unfortunately for files created by PowerShell (such as our documentation) the line endings will always be set to the line endings of the operating system that was in use when they were generated (see https://github.com/PowerShell/PowerShell/issues/2872).  
Therefore to ensure the line endings stay consistent (so we can avoid a messy git history) we require that all documentation is generated with LF line endings.  
To make this easier we include an editorconfig file in the repository which will automatically set the line endings to LF for those files.  
For those not using an editor that supports editorconfig then the build tasks will automatically convert the line endings for you.
