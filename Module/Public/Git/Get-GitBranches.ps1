function Get-GitBranches
{
    [CmdletBinding()]
    param
    (
        # The path to the repository
        [Parameter(Mandatory = $false, Position = 0)]
        [string]
        $RepositoryPath = $PWD
    )
    
    begin
    {
        
    }
    
    process
    {
        Assert-Directory $RepositoryPath -ErrorAction 'Stop'
        try
        {
            $Branches = Invoke-NativeCommand `
                -FilePath 'git' `
                -ArgumentList @('branch', '--format=%(refname:short)') `
                -WorkingDirectory $RepositoryPath `
                -SuppressOutput `
                -PassThru `
                -ErrorAction 'Stop' | Select-Object -ExpandProperty 'OutputContent'
        }
        catch
        {
            throw $_.Exception.Message
        }
    }
    
    end
    {
        if ($Branches)
        {
            return $Branches
        }
        else
        {
            return $null
        }
    }
}