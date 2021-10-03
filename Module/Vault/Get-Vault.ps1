function Get-Vault
{
    [CmdletBinding()]
    param (
        # The version of Vault to use.
        # Defaults to the value of global:VaultVersion but if that is not set then a default version of 1.8.2 is used
        [Parameter(
            Mandatory = $false,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [version]
        $VaultVersion = "$(if($global:RepoVaultVersion){"$global:RepoVaultVersion"}else{'1.8.2'})",

        # The path to download the binary to
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Path')]
        [string]
        $DownloadPath
    )
    # Make sure the directory path is good
    try
    {
        $DownloadPathInfo = Get-Item $DownloadPath -Force
        if (!$DownloadPathInfo.PSIsContainer)
        {
            Write-Error "$DownloadPath does not appear to be a directory"
        }
    }
    catch
    {
        throw "Error with DownloadPath.`n$($_.Exception.Message)"
    }

    # If we have desktop PoSh we must be on Windows
    if ($PSVersionTable.PSEdition -eq 'Desktop')
    {
        $VaultDownloadURI = "https://releases.hashicorp.com/vault/$VaultVersion/vault_$($VaultVersion)_windows_amd64.zip"
        $VaultPath = Join-Path $DownloadPath 'vault.exe'
    }
    else
    {
        switch -regex ($PSVersionTable.OS)
        {
            '^[M|m]icrosoft [W|w]indows'
            {
                $VaultDownloadURI = "https://releases.hashicorp.com/vault/$VaultVersion/vault_$($VaultVersion)_windows_amd64.zip"
                $VaultPath = Join-Path $DownloadPath 'vault.exe'
            }
            '^[D|d]arwin'
            {
                $VaultDownloadURI = "https://releases.hashicorp.com/vault/$VaultVersion/vault_$($VaultVersion)_darwin_amd64.zip"
                $Chmod = $true
                $VaultPath = Join-Path $DownloadPath 'vault'
            }
            '^[L|l]inux'
            {
                $VaultDownloadURI = "https://releases.hashicorp.com/vault/$VaultVersion/vault_$($VaultVersion)_linux_amd64.zip"
                $Chmod = $true
                $VaultPath = Join-Path $DownloadPath 'vault'
            }
            Default
            {
                Write-Error "Unknown OS: $($PSVersionTable.OS)"
            }
        }
    }
    # Download and extract Vault
    $VaultZipFile = Join-Path $DownloadPath -ChildPath 'vault.zip'
    # If the ZIP file already exists it seems it won't trigger another download so remove it first.
    if ((Test-Path $VaultZipFile) -eq $true)
    {
        Write-Verbose "Removing previously downloaded archive"
        try
        {
            Remove-Item $VaultZipFile -Force -Confirm:$false
        }
        catch
        {
            # Ignore it and hope for the best using the old zip...
        }
    }
    Write-Verbose "Downloading Vault binary..."
    try
    {
        Invoke-DownloadMethod -DownloadURI $VaultDownloadURI -OutFile $VaultZipFile
        Expand-Archive -LiteralPath $VaultZipFile -DestinationPath $DownloadPath -Force # Force for when we're running locally and want overwrite old files
        if ($Chmod -eq $true)
        {
            $Output = & chmod +x $VaultPath
            if ($LASTEXITCODE -ne 0)
            {
                $Output
                Write-Error "Failed to make vault executable"
            }
        }
    }
    catch
    {
        Write-Error $_.Exception.Message
    }
    # Providing we've made it this far then set the vault env var
    $env:VaultPath = $VaultPath
    try
    {
        Set-Alias 'vault' -Value $VaultPath -Scope global
    }
    catch
    {
        Write-Error $_.Exception.Message
    }
}