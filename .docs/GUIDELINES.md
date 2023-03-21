# Guidelines
## Writing cmdlets/functions

### Don't hardcode paths!
Don't form paths by passing in separators (e.g. `C:\`, `/usr/`), use the tools PowerShell gives you!

* [`Resolve-Path`](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/resolve-path?view=powershell-7.1) can be used to validate user submitted paths or resolve the path to commands/aliases.
* [`Join-Path`](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/join-path?view=powershell-7.1) can be used to construct paths _(top tip: you can specify multiple values in `-AdditionalChildPaths`)_
* [`Convert-Path`](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/convert-path?view=powershell-7.1) by default PowerShell stores paths as a `PSPath` which can break environment variables, Convert-Path converts a PSPath to the standard path format for your OS.
  
By using these you give your code a much higher chance of working across different operating systems. 😊

### OS specific cmdlets
By default we treat all cmdlets as cross-platform but there may be instances where your code will only work on certain operating systems, in these cases you should call `Test-OperatingSystem` at the beginning of your cmdlet with the supported OSes as the first (and only) parameter.  
If the running OS isn't in the supported list then an exception will be raised.
Example:
```powershell
> $isLinux
> $True
> Test-OperatingSystem 'Linux' -Verbose
> VERBOSE: This cmdlet is supported on Linux
> Test-OperatingSystem 'Linux','macOS' -Verbose
> VERBOSE: This cmdlet is supported on Linux
> Test-OperatingSystem 'Linux','Windows' -Verbose
> Exception: This cmdlet is not compatible with Windows
```

### Writing snippets
We include a bunch of helper snippets to make working with Brownserve projects a little easier, from time-to-time these may need updating.  
By far the easiest way to do this is to create a template file with your desired changes and then use the `snippet-creator` extension to convert them into snippets.  
As it stands these extension doesn't handle PowerShell all that well so you'll need to regex replace `$` signs.

The following regex statements should help with that.  
Find with:
```
\$([^{])
```

Replace with:
```
\\\$$1
```