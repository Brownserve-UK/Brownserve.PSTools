function Copy-VSCodeDevcontainer
{
    [CmdletBinding()]
    param
    (
        # The source of the devcontainer
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $DevcontainerTemplate = (Join-Path $PSScriptRoot -ChildPath 'devcontainer'),
        
        # The destination to the repo to copy these too
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string]
        $RepoPath
    )
    # Make sure our repo path is valid
    try
    {
        $RepoDetails = Get-Item $RepoPath
        if (!$RepoDetails.PSIsContainer)
        {
            Write-Error "$RepoPath does not appear to be a valid repo."
        }
    }
    catch
    {
        throw $_.Exception.Message
    }
        
    # Make sure the snippet path is valid
    if (!(Test-Path $DevcontainerTemplate))
    {
        throw "$DevcontainerTemplate does not exist"
    }
    
    # Now try to copy our devcontainer over
    $DevcontainerPath = Join-Path $RepoPath '.devcontainer'
    if (Test-Path $DevcontainerPath)
    {
        Write-Verbose ".devcontainer already exists."
        Return
    }
    else
    {
        try
        {
            # Create the directory
            Write-Verbose 'Copying .devcontainer template'
            Copy-Item $DevcontainerTemplate -Destination $DevcontainerPath -Recurse
        }
        catch
        {
            Write-Error "Failed to copy devcontainer directory.`n$($_.Exception.Message)"
        }
    }
}