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
    # Whether the path is a directory or file
    [string] $PathType
    

    # These first 2 constructors allow us to easily spin up InitPath's from objects.
    InitPath([pscustomobject]$InitPath)
    {
        $RequiredProps = @('path','VariableName','PathType')
        foreach ($Prop in $RequiredProps)
        {
            if (!$InitPath.$Prop)
            {
                throw "Object missing property '$Prop'"
            }
            else
            {
                $this.$Prop = $InitPath.$Prop
            }
        }
        if ($InitPath.ChildPaths)
        {
            $this.ChildPaths = $InitPath.ChildPaths
        }
        if ($InitPath.Description)
        {
            $this.Description = $InitPath.Description
        }
    }

    InitPath([hashtable]$InitPath)
    {
        $RequiredKeys = @('path','VariableName','PathType')
        foreach ($Key in $RequiredKeys)
        {
            if (!$InitPath.$Key)
            {
                throw "Hashtable missing property '$Key'"
            }
            else
            {
                $this.$Key = $InitPath.$Key
            }
        }
        if ($InitPath.ChildPaths)
        {
            $this.ChildPaths = $InitPath.ChildPaths
        }
        if ($InitPath.Description)
        {
            $this.Description = $InitPath.Description
        }
    }
}

enum BrownserveCICD
{
    GitHubActions
    TeamCity
}

enum BrownserveRepoProjectType
{
    PowerShellModule
    BrownservePSTools
    Generic
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

class PaketDependencyRule
{
    [string]$Source
    [string]$PackageName

    PaketDependencyRule([hashtable]$Hashtable)
    {
        $RequiredKeys = @('Source', 'PackageName')
        foreach ($Key in $RequiredKeys)
        {
            if (!$Hashtable.$Key)
            {
                throw "Hashtable missing key '$Key'"
            }
            else
            {
                $this.$Key = $Hashtable.$Key
            }
        }
    }

    PaketDependencyRule([pscustomobject]$Object)
    {
        $RequiredKeys = @('Source', 'PackageName')
        foreach ($Key in $RequiredKeys)
        {
            if (!$Object.$Key)
            {
                throw "Object missing property '$Key'"
            }
            else
            {
                $this.$Key = $Object.$Key
            }
        }
    }
}

class PaketDependency
{
    [PaketDependencyRule[]]$Rule
    [string]$Comment

    PaketDependency([hashtable]$Hashtable)
    {
        if (!$Hashtable.Rule)
        {
            throw "Hashtable missing key 'Rule'"
        }
            
        $this.Rule = $Hashtable.Rule
        if ($Hashtable.Comment)
        {
            # Try to ensure every line starts with the pound symbol
            $LocalComment = $Hashtable.Comment -split "`n"
            $SanitizedComment = ''
            $LocalComment | ForEach-Object {
                if ($_ -notmatch '^\#')
                {
                    $SanitizedComment += "# $_"
                }
                else
                {
                    $SanitizedComment += $_
                }
                if ($_ -notmatch $LocalComment[-1])
                {
                    $SanitizedComment += "`n"
                }
            }
            $this.Comment = $SanitizedComment
        }
    }

    PaketDependency([pscustomobject]$Object)
    {
        if (!$Object.Rule)
        {
            throw "Hashtable missing key 'Rule'"
        }
            
        $this.Rule = $Object.Rule
        if ($Object.Comment)
        {
            # Try to ensure every line starts with the pound symbol
            $LocalComment = $Object.Comment -split "`n"
            $SanitizedComment = ''
            $LocalComment | ForEach-Object {
                if ($_ -notmatch '^\#')
                {
                    $SanitizedComment += "# $_"
                }
                else
                {
                    $SanitizedComment += $_
                }
                if ($_ -notmatch $LocalComment[-1])
                {
                    $SanitizedComment += "`n"
                }
            }
            $this.Comment = $SanitizedComment
        }
    }
}

class PackageAlias
{
    # The alias that should be set
    [string] $Alias
    # The name of the binary/executable/file to have the alias set
    [string] $FileName
    # If specified will create a global variable that also points to the same file (for external apps that can't see PowerShell aliases)
    [string] $VariableName

    PackageAlias([hashtable]$Hash)
    {
        $RequiredKeys = @('Alias','FileName')
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
        if ($Hash.VariableName)
        {
            $this.VariableName = $Hash.VariableName
        }
    }

    PackageAlias([pscustomobject]$Obj)
    {
        $RequiredProps = @('Alias','FileName')
        foreach ($Prop in $RequiredProps)
        {
            if (!$Obj.$Prop)
            {
                throw "Object missing property '$Prop'"
            }
            else
            {
                $this.$Prop = $Obj.$Prop
            }
        }
        if ($Obj.VariableName)
        {
            $this.VariableName = $Obj.VariableName
        }
    }
}