function Switch-GitBranch
{
    [CmdletBinding()]
    param
    (
        # The repository path
        [Parameter(Mandatory = $false)]
        [string]
        $RepositoryPath = $PWD,

        # The branch to be created
        [Parameter(Mandatory = $true)]
        [string]
        $BranchName
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
                -ArgumentList @('checkout', $BranchName) `
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
                'did not match any file\(s\) known to git'
                {
                    $ErrorMessage += "`nThis error indicates that the branch you are attempting to checkout does not yet exist."
                }
            }
            throw $ErrorMessage
        }
    }
    
    end
    {
        
    }
}