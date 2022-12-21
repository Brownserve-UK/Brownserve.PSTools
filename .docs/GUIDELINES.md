# Guidelines
## Writing cmdlets/functions

### Don't hardcode paths!
Don't form paths by passing in separators (e.g. `C:\`, `/usr/`), use the tools PowerShell gives you!

* [`Resolve-Path`](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/resolve-path?view=powershell-7.1) can be used to validate user submitted paths or resolve the path to commands/aliases.
* [`Join-Path`](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/join-path?view=powershell-7.1) can be used to construct paths _(top tip: you can specify multiple values in `-AdditionalChildPaths`)_
* [`Convert-Path`](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/convert-path?view=powershell-7.1) by default PowerShell stores paths as a `PSPath` which can break environment variables, Convert-Path converts a PSPath to the standard path format for your OS.
  
By using these you give your code a much higher chance of working across different operating systems. 😊

### OS specific cmdlets
By default we treat all cmdlets as cross-platform but there may be instances where your code will only work on certain operating systems, in these cases you need to mark them using the `[Compatible with:]` tag in the help description to list all the operating systems that your code is compatible with.  

For example if your code is only compatible with macOS and Linux you would add `[Compatible with: macOS, Linux]`, if it's only compatible with Windows you would add `[Compatible with: Windows]`.
Take a look at [Install-ChocolateyPackage](Brownserve.PSTools/Public/Install-ChocolateyPackage.md) for an example of how this works.

It's also a good idea to have logic in your code to bottom out if it isn't on the right platform.

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