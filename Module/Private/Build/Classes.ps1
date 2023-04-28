# Some types/classes for use in our 'build' cmdlets
# This class is used to give us a nice easy way to manage our paths for our init scripts
class InitPath
{
    # The name of the variable to be created in the _init script
    [string] $VariableName
    # The path to use for the variable in the _init script
    [string] $Path
    # When forming paths that require children these are the additional values to use
    [array] $ChildPaths
    # The description of the variable to be set in the _init script
    [string] $Description
    # When using permanent paths this is the local location to the path
    [string] $LocalPath
    

    # These first 2 constructors allow us to easily spin up InitPath's from objects.
    InitPath([pscustomobject]$InitPath)
    {
        $this.Path = $InitPath.path
        $this.VariableName = $InitPath.VariableName
        if ($InitPath.ChildPaths)
        {
            $this.ChildPaths = $InitPath.ChildPaths
        }
        if ($InitPath.Description)
        {
            $this.Description = $InitPath.Description
        }
        if ($InitPath.LocalPath)
        {
            $this.LocalPath = $InitPath.LocalPath
        }
    }

    InitPath([hashtable]$InitPath)
    {
        $this.Path = $InitPath.path
        $this.VariableName = $InitPath.VariableName
        if ($InitPath.ChildPaths)
        {
            $this.ChildPaths = $InitPath.ChildPaths
        }
        if ($InitPath.Description)
        {
            $this.Description = $InitPath.Description
        }
        if ($InitPath.LocalPath)
        {
            $this.LocalPath = $InitPath.LocalPath
        }
    }

    # Allow us to set the values by using 2 strings
    InitPath([string]$VariableName, [string]$Path)
    {
        $this.Path = $Path
        $this.VariableName = $VariableName
    }

    # Allow us to set the values by 3 strings, so we can have additional child paths if we want
    InitPath([string]$VariableName, [string]$Path, [array]$ChildPaths)
    {
        $this.Path = $Path
        $this.VariableName = $VariableName
        $this.ChildPaths = $ChildPaths
    }

    
}

enum BrownserveCICD
{
    GitHubActions
    TeamCity
}
<#
    This class is used to create GitHub Actions workflow jobs
#>
class GitHubActionsJob
{
    [string]$JobTitle
    [string]$RunsOn
    [hashtable[]]$Steps # Can't used ordered here, https://github.com/PowerShell/vscode-powershell/issues/1969#issuecomment-651874245

    GitHubActionsJob([hashtable]$Hash)
    {
        $RequiredKeys = @('JobTitle', 'RunsOn', 'Steps')
        foreach ($Key in $RequiredKeys)
        {
            if (!$Hash.$Key)
            {
                throw "Hashtable missing key '$Key'"
            }
            else
            {
                $this.$Key = $Hash.$Key
            }
        }
    }
}