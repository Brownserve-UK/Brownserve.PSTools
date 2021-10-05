function Invoke-DownloadMethod
{
    [CmdletBinding()]
    param
    (
        # The download URI
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string]
        $DownloadURI,

        # The place to store the download
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]
        $OutFile
    )
    if ($PSVersionTable.PSEdition -eq 'Desktop')
    {
        try
        {
            $BITs = Get-Service -Name BITs | Where-Object { $_.Status -eq "Running" }
        }
        catch
        {
            Write-Verbose "Using Invoke-WebRequest"
            $DownloadMethod = 'WebRequest'
        }
        if ($BITs)
        {
            Write-Verbose "Using BITs"
            $DownloadMethod = 'BITs'
        }
        else
        {
            Write-Verbose "BITs not running, falling back to WebRequest"
            $DownloadMethod = 'WebRequest'
        }
    }
    else
    {
        Write-Verbose "Using Invoke-WebRequest"
        $DownloadMethod = 'WebRequest'
    }
    switch ($DownloadMethod)
    {
        'WebRequest'
        {
            try
            {
                Invoke-WebRequest -Uri $DownloadURI -OutFile $OutFile
            }
            catch
            {
                Write-Error $_.Exception.Message
            }
        }
        'BITs'
        {
            try
            {
                Start-BitsTransfer -Source $DownloadURI -Destination $OutFile
            }
            catch
            {
                Write-Error $_.Exception.Message
            }        
        }
    }
}