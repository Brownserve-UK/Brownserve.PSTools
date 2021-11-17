function Copy-VSCodeFile
{
    [CmdletBinding()]
    param
    (
        # The destination to the repo
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string]
        $RepoPath,

        # The source file to copy
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $VSCodeFile
    )
    
    # Try to be clever and strip out the .vscode directory if it has been passed.
    if ($RepoPath -match "\.vscode$")
    {
        $RepoPath = $RepoPath -replace '.vscode', ''
    }
    
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

    # Make sure the file path is valid
    $VSCodeFilePath = Join-Path $PSScriptRoot $VSCodeFilePath
    if (!(Test-Path $VSCodeFilePath))
    {
        throw "$VSCodeFilePath does not exist"
    }

    $VSCodePath = Join-Path $RepoPath -ChildPath '.vscode'
    if (!(Test-Path $VSCodePath))
    {
        try
        {
            Write-Verbose "Setting up new .vscode directory at $VSCodePath"
            New-Item $VSCodePath -ItemType Directory | Out-Null
            Write-Verbose "Copying settings to $VSCodePath"
            Copy-Item $VSCodeFilePath -Destination $VSCodePath
        }
        catch
        {
            throw "Failed to set-up .vscode directory.`n$($_.Exception.Message)"
        }
    }
    else
    {
        Write-Verbose "Copying settings to $VSCodePath"
        # Overwrite them if they exist...
        Copy-Item $VSCodeFilePath -Destination $VSCodePath -Force
    }
}