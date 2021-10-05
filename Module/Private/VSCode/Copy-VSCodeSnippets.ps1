function Copy-VSCodeSnippets
{
    [CmdletBinding()]
    param
    (
        # The source of the snippets
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $SnippetsSource = (Join-Path $PSScriptRoot -ChildPath 'brownserve-pstools.code-snippets'),
        
        # The destination to the repo
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string]
        $RepoPath
    )
    # Try to be clever and strip out the .vscode directory if it has been passed.
    if ($RepoPath -match "\.vscode$")
    {
        $RepoPath = $RepoPath -replace '.vscode',''
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
    
    # Make sure the snippet path is valid
    if (!(Test-Path $SnippetsSource))
    {
        throw "$SnippetSource does not exist"
    }

    if ($SnippetsSource -notmatch "\.code-snippets$")
    {
        throw "$SnippetSource does not appear to be a valid VSCode snippet file"
    }

    $VSCodePath = Join-Path $RepoPath -ChildPath '.vscode'
    if (!(Test-Path $VSCodePath))
    {
        try
        {
            Write-Verbose "Setting up new .vscode directory at $VSCodePath"
            New-Item $VSCodePath -ItemType Directory | Out-Null
            Write-Verbose "Copying snippets to $VSCodePath"
            Copy-Item $SnippetsSource -Destination $VSCodePath
        }
        catch
        {
            throw "Failed to set-up .vscode directory.`n$($_.Exception.Message)"
        }
    }
    else
    {
        Write-Verbose "Copying snippets to $VSCodePath"
        # Overwrite them if they exist...
        Copy-Item $SnippetsSource -Destination $VSCodePath -Force
    }
}