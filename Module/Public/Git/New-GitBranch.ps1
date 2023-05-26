function New-GitBranch
{
    [CmdletBinding()]
    param
    (
        # The repository path
        [Parameter(Mandatory = $true)]
        [string]
        $RepositoryPath,

        # The branch to be created
        [Parameter(Mandatory = $true)]
        [string]
        $BranchName,

        # Whether or not to checkout the branch upon creation
        [Parameter(Mandatory = $false)]
        [bool]
        $Checkout = $true
    )
    
    begin
    {
        Assert-Directory $RepositoryPath -ErrorAction 'Stop'
    }
    
    process
    {
        try
        {
            Invoke-NativeCommand `
                -FilePath 'git' `
                -ArgumentList @('branch', $BranchName) `
                -WorkingDirectory $RepositoryPath `
                -SuppressOutput `
                -ErrorAction 'Stop'
        }
        catch
        {
            $ErrorMessage = $_.Exception.Message
            # Give some helpers for more commonly encountered errors
            switch -regex ($ErrorMessage)
            {
                'fatal\: not a valid object name'
                {
                    $ErrorMessage += "`nIt's possible that the repo has had no commits to the branch that you are trying to branch from."
                }
            }
            throw "Failed to create new branch.`n$ErrorMessage"
        }
        if ($Checkout -eq $true)
        {
            try
            {
                Switch-GitBranch `
                    -RepositoryPath $RepositoryPath `
                    -BranchName $BranchName `
                    -ErrorAction 'Stop'
            }
            catch
            {
                throw "Could not switch to branch.`n$($_.Exception.Message)"
            }
        }
    }
    
    end
    {
        
    }
}