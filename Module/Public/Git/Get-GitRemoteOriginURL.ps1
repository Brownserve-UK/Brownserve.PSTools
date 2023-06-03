function Get-GitRemoteOriginURL
{
    [CmdletBinding()]
    param
    (
        # The repository path
        [Parameter(Mandatory = $false)]
        [string[]]
        $RepositoryPath = $PWD
    )
    
    begin
    {
        
    }
    
    process
    {
        $Return = @()
        $RepositoryPath | ForEach-Object {
            Assert-Directory $_ -ErrorAction 'Stop'
            try
            {
                $RemoteURL = Invoke-NativeCommand `
                    -FilePath 'git' `
                    -ArgumentList @('config', '--get', 'remote.origin.url') `
                    -WorkingDirectory $_ `
                    -SuppressOutput `
                    -PassThru `
                    -ErrorAction 'Stop'
                $RemoteURL = $RemoteURL | Select-Object -ExpandProperty 'OutputContent'
                if ($RemoteURL)
                {
                    $Return += $RemoteURL
                }
            }
            catch
            {
                throw "Failed to determine remote URL for '$_'`n$($_.Exception.Message)"
            }
        }
    }
    
    end
    {
        if ($Return.count -gt 0)
        {
            return $Return
        }
        else
        {
            return $null
        }
    }
}