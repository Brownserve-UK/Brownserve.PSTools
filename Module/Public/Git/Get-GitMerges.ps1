<#
.SYNOPSIS
    Returns a list of merge commits for a given GitHub repository
.DESCRIPTION
    Searches the git log for merges and returns the commit hash
#>
function Get-GitMerges
{
    [CmdletBinding()]
    param
    (
        # The path to the repository
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string]
        $RepositoryPath = $PWD,

        # The branch to search for merges in
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]
        $HeadBranch = 'HEAD',

        # The feature branch
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [string]
        $ReferenceBranch,

        # Follow only the first parent commit upon seeing a merge commit.
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
        )]
        [bool]
        $FirstParentOnly = $true,

        # Any pretty options to pass
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 4
        )]
        [string]
        $PrettyOptions,

        # If set will omit the commit header (only supported on newer versions of git and when pretty options are set)
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 5
        )]
        [switch]
        $NoCommitHeader
    )
    begin
    {
        if ($NoCommitHeader -and !$PrettyOptions)
        {
            throw "Cannot use '-NoCommitHeader' when '-PrettyOptions' has not been specified"
        }
    }
    process
    {
        if ($ReferenceBranch)
        {
            $CommitSearcher = "$ReferenceBranch..$HeadBranch"
        }
        else
        {
            $CommitSearcher = $HeadBranch
        }
        $Arguments = @('rev-list', $CommitSearcher, '--merges')
        if ($FirstParentOnly -eq $true)
        {
            $Arguments += '--first-parent'
        }
        if ($PrettyOptions)
        {
            $Arguments += "--pretty=$PrettyOptions"
        }
        if ($NoCommitHeader)
        {
            $Arguments += '--no-commit-header'
        }
        try
        {
            $Merges = Invoke-NativeCommand `
                -FilePath 'git' `
                -Arguments $Arguments `
                -PassThru `
                -SuppressOutput | Select-Object -ExpandProperty OutputContent
        }
        catch
        {
            throw "Failed to query git merges.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        if ($Merges)
        {
            return $Merges
        }
        else
        {
            return $null
        }
    }
}