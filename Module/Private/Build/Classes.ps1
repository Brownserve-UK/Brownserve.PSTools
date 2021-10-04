# Some types/classes for use in our 'build' cmdlets
# This class is used to give us a nice easy way to manage our paths for our init scripts
class InitPath
{
    [string] $VariableName
    [string] $Path

    # This constructor allows us to pass in pscustomobject's
    InitPath([pscustomobject]$InitPath)
    {
        $this.Path = $InitPath.path
        $this.VariableName = $InitPath.VariableName
    }

    # Allow us to set the values by using 2 strings
    InitPath([string]$VariableName, [string]$Path)
    {
        $this.Path = $Path
        $this.VariableName = $VariableName
    }

    InitPath([hashtable]$InitPath)
    {
        $this.Path = $InitPath.path
        $this.VariableName = $InitPath.VariableName
    }
}