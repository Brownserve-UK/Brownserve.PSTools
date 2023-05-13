function Get-VSCodeRecommendedExtensions
{
    [CmdletBinding()]
    param
    (
        # The path to the repo where spellings should be added
        [Parameter(Mandatory = $true)]
        [string]
        $WorkspacePath
    )
    
    begin
    {
        
    }
    
    process
    {
        Assert-Directory $WorkspacePath -ErrorAction 'stop'
        $RepoVSCodePath = Join-Path $WorkspacePath '.vscode'
        $RepoVSCodeExtensionsPath = Join-Path $RepoVSCodePath 'extensions.json'
        if (Test-Path $RepoVSCodeExtensionsPath)
        {
            try
            {
                $CurrentExtensions = Get-Content $RepoVSCodeExtensionsPath -Raw | 
                    ConvertFrom-Json -AsHashtable |
                        Select-Object -ExpandProperty 'recommendations'
                if (!$CurrentExtensions)
                {
                    $CurrentExtensions = $null
                }
            }
            catch
            {
                throw "Failed to get current extensions list from '$RepoVSCodeExtensionsPath'.`n$($_.Exception.Message)"
            }
        }
        else
        {
            $CurrentExtensions = $null
        }
    }
    
    end
    {
        if ($CurrentExtensions)
        {
            Return $CurrentExtensions
        }
        else
        {
            return $null
        }
    }
}