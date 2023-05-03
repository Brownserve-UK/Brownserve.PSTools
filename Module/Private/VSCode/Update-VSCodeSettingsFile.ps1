function Update-VSCodeSettingsFile
{
    [CmdletBinding()]
    param
    (
        # The path to the repo
        [Parameter(Mandatory = $true)]
        [string]
        $RepoPath,

        # The settings to be added
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Settings,

        # If the settings already exist then forcefully overwrite them
        [Parameter(Mandatory = $false)]
        [switch]
        $Force
    )
    
    begin
    {
        
    }
    
    process
    {
        Assert-Directory $RepoPath -ErrorAction 'stop'
        $RepoVSCodePath = Join-Path $RepoPath '.vscode'
        $RepoVSCodeSettingsPath = Join-Path $RepoVSCodePath 'settings.json'

        if (!Test-Path $RepoVSCodeSettingsPath)
        {
            throw "Cannot find VSCode settings at '$RepoVSCodeSettingsPath'"
        }
        else
        {
            try
            {
                $CurrentSettings = Get-Content $RepoVSCodeSettingsPath -Raw | ConvertFrom-Json
            }
            catch
            {
                throw "Failed to import current VSCode settings.`n$($_.Exception.Message)"
            }
        }

        if ($CurrentSettings)
        {
            $NewSettings = $CurrentSettings
            $Settings.GetEnumerator() | ForEach-Object {
                if ($NewSettings.$_.Key)
                {
                    if ($Force)
                    {
                        $NewSettings.$_.Key = $_.Value
                    }
                    else
                    {
                        throw "'$($NewSettings.$_.Key)' already configured. Use '-Force' to overwrite"
                    }
                }
                else
                {
                    $NewSettings.Add($_.Key, $_.Value)
                }
            }
        }
    }
    
    end
    {
        if ($NewSettings)
        {
            try
            {
                $NewSettingsJson = $NewSettings | ConvertTo-Json -Depth 100
                Set-Content $RepoVSCodeSettingsPath -Value $NewSettingsJson -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed ot update the settings file at '$RepoVSCodeSettingsPath'.`n$($_.Exception.Message)"
            }
        }
    }
}