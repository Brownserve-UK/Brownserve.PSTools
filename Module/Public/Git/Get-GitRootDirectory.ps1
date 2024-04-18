function Get-GitRootDirectory
{
    [CmdletBinding()]
    param
    (
        # The path to the repository
        [Parameter(Mandatory = $false, Position = 0)]
        [string[]]
        $RepositoryPath = $PWD
    )
    begin
    {
    }
    process
    {
        foreach ($Path in $RepositoryPath)
        {
            try
            {
                $Arguments = @('rev-parse', '--show-toplevel')
                $RepoRoot = Invoke-NativeCommand `
                    -FilePath 'git' `
                    -ArgumentList $Arguments `
                    -WorkingDirectory $Path `
                    -SuppressOutput `
                    -PassThru `
                    -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to get the root directory of the git repository at '$Path'.`n$($_.Exception.Message)"
            }
            $RepoRoot = $RepoRoot.OutputContent.Trim()
            Write-Output $RepoRoot
        }
    }
    end
    {
    }
}
