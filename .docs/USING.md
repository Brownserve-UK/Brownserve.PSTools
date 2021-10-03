# Using in CI/CD/builds
If you have a build that you'd like use Brownserve.BuildTools with then the easiest way to get going with this is to use the Initialize-BrownserveBuildRepo cmdlet which will bootstrap your repo auto-magically for you.

>This cmdlet can be run against either a brand new repo or an existing one as it is mostly non-destructive, though care should be taken when pointing at an existing repo as it will overwrite '.build/_init.ps1' if it exists.  
With this in mind it's recommended that if you're running this against an existing repo you do so on a new branch!

# Using with another PowerShell script/module
There may be instances where you want to use these tools withing other PowerShell modules or scripts, for that you can simply use `Install-Module -Name 'Brownserve.BuildTools'`