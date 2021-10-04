# Some types/classes for use in our 'build' cmdlets
class EphemeralPath
{
    [string] $VariableName
    [string] $Path

    # This constructor allows us to pass in pscustomobject's
    EphemeralPath([pscustomobject]$EphemeralPath)
    {
        $this.Path = $EphemeralPath.path
        $this.VariableName = $EphemeralPath.VariableName
    }

    # Allow us to set the values by using 2 strings
    EphemeralPath([string]$VariableName, [string]$Path)
    {
        $this.Path = $Path
        $this.VariableName = $VariableName
    }

    EphemeralPath([hashtable]$EphemeralPath)
    {
        $this.Path = $EphemeralPath.path
        $this.VariableName = $EphemeralPath.VariableName
    }
}