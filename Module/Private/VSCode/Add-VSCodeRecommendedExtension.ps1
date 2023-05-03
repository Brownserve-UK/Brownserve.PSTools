function Add-VSCodeRecommendedExtension
{
    [CmdletBinding()]
    param
    (
        # The path to the repo where spellings should be added
        [Parameter(Mandatory = $true)]
        [string]
        $RepoPath,

        # The extensions to recommend
        [Parameter(AttributeValues)]
        [string[]]
        $Extension
    )
    
    begin
    {
        
    }
    
    process
    {
        Assert-Directory $RepoPath -ErrorAction 'stop'
        $RepoVSCodePath = Join-Path $RepoPath '.vscode'
        $RepoVSCodeExtensionsPath = Join-Path $RepoVSCodePath 'extensions.json'
        if (!(Test-Path $RepoVSCodeExtensionsPath))
        {
            $Create = $true
            try
            {
                $CurrentExtensions = Get-Content $RepoVSCodeExtensionsPath -Raw | 
                    ConvertFrom-Json -AsHashtable |
                        Select-Object -ExpandProperty 'recommendations'
            }
            catch
            {
                throw "Failed to get current extensions list.`n$($_.Exception.Message)"
            }
        }
        else
        {
            $Create = $false
            $CurrentExtensions = @()

        }

        $NewExtensions = $CurrentExtensions
        $Extension | ForEach-Object {
            if ($_ -notin $NewExtensions)
            {
                $NewExtensions += $_
            }
        }
    }
    
    end
    {
        if ($NewExtensions.Count -gt 0)
        {
            $NewExtensionsJSON = @{
                recommendations = $NewExtensions
            } | ConvertTo-Json -Depth 100
            if ($Create -eq $true)
            {
                try
                {
                    New-Item $RepoVSCodeExtensionsPath -Value $NewExtensionsJSON -ErrorAction 'Stop'
                }
                catch
                {
                    throw "Failed to create extensions file.`n$($_.Exception.Message)"
                }
            }
            else
            {
                try
                {
                    Set-Content $RepoVSCodeExtensionsPath -Value $NewExtensionsJSON -ErrorAction 'Stop'
                }
                catch
                {
                    throw "Failed to update extensions file.`n$($_.Exception.Message)"
                }
            }
        }
    }
}