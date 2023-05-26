function Get-GitCurrentBranch
{
    [CmdletBinding()]
    param
    (
        # The repository path
        [Parameter(Mandatory = $true)]
        [string[]]
        $RepositoryPath
    )
    
    begin
    {
        $Return = @()
    }
    
    process
    {
        $RepositoryPath | ForEach-Object {
            Assert-Directory $_ -ErrorAction 'Stop'
            try
            {
                $CurrentBranch = Invoke-NativeCommand `
                    -FilePath 'git' `
                    -ArgumentList @('rev-parse', '--abbrev-ref', 'HEAD') `
                    -WorkingDirectory $_ `
                    -SuppressOutput `
                    -PassThru `
                    -ErrorAction 'Stop'
                $CurrentBranch = $CurrentBranch | Select-Object -ExpandProperty 'OutputContent'
            }
            catch
            {
                $ErrorMessage = $_.Exception.Message
                # Give some helpers for more commonly encountered errors
                switch -regex ($ErrorMessage)
                {
                    "ambiguous argument 'HEAD'"
                    {
                        $ErrorMessage += "`nThis error indicates that the repo may not have any commits on any branches yet."
                    }
                }
                throw $ErrorMessage
            }
            if ($CurrentBranch)
            {
                $Return += $CurrentBranch
            }
        }
    }
    
    end
    {
        if ($Return.Count -gt 0)
        {
            if ($Return.Count -eq 1)
            {
                return $Return[0]
            }
            else
            {
                return $Return
            }
        }
        else
        {
            return $null
        }
    }
}