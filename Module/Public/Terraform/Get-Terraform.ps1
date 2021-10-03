function Get-Terraform
{
    [CmdletBinding()]
    param (
        # The version of Terraform to use.
        # Defaults to global:TerraformVersion but if that is not set then a default version of 1.0.7 is used
        [Parameter(
            Mandatory = $false,
            Position = 0
        )]
        [version]
        $TerraformVersion = "$(if ($Global:RepoTerraformVersion){"$Global:RepoTerraformVersion"}else{'1.0.8'})",

        # The path to download the binary to
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [Alias('path')]
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
        $TerraformDownloadURI = "https://releases.hashicorp.com/terraform/$TerraformVersion/terraform_$($TerraformVersion)_windows_amd64.zip"
        $TerraformPath = Join-Path $DownloadPath -ChildPath 'terraform.exe'
    }
    else
    {
        switch -regex ($PSVersionTable.OS)
        {
            '^[M|m]icrosoft [W|w]indows'
            {
                $TerraformDownloadURI = "https://releases.hashicorp.com/terraform/$TerraformVersion/terraform_$($TerraformVersion)_windows_amd64.zip"
                $TerraformPath = Join-Path $DownloadPath -ChildPath 'terraform.exe'
            }
            '^[D|d]arwin'
            {
                $TerraformDownloadURI = "https://releases.hashicorp.com/terraform/$TerraformVersion/terraform_$($TerraformVersion)_darwin_amd64.zip"
                $Chmod = $true
                $TerraformPath = Join-Path $DownloadPath -ChildPath 'terraform'
            }
            '^[L|l]inux'
            {
                $TerraformDownloadURI = "https://releases.hashicorp.com/terraform/$TerraformVersion/terraform_$($TerraformVersion)_linux_amd64.zip"
                $Chmod = $true
                $TerraformPath = Join-Path $DownloadPath -ChildPath 'terraform'
            }
            Default
            {
                Write-Error "Unknown OS: $($PSVersionTable.OS)"
            }
        }
    }
    # Download and extract Terraform
    $TerraformZipFile = Join-Path $DownloadPath 'terraform.zip'
    # If the ZIP file already exists it seems it won't trigger another download so let's try removing it first
    if ((Test-Path $TerraformZipFile) -eq $true)
    {
        Write-Verbose 'Removing previously downloaded archive'
        try
        {
            Remove-Item $TerraformZipFile -Force -Confirm:$false
        }
        catch
        {
            # Ignore it and hope for the best using the old zip...
        }
    }
    Write-Verbose 'Downloading Terraform binary...'
    try
    {
        Invoke-DownloadMethod -DownloadURI $TerraformDownloadURI -OutFile $TerraformZipFile
        Expand-Archive -LiteralPath $TerraformZipFile -DestinationPath $DownloadPath -Force # Force for when we're running locally and want to overwrite old files
        if ($Chmod -eq $true)
        {
            $Output = & chmod +x $TerraformPath
            if ($LASTEXITCODE -ne 0)
            {
                $Output
                Write-Error 'Failed to make Terraform executable'
            }
        }
    }
    catch
    {
        Write-Error $_.Exception.Message
    }
    # Providing everything has completed ok, set the terraform path
    $env:TerraformPath = $TerraformPath
    try
    {
        Set-Alias -Name 'terraform' -Value $TerraformPath -Scope global
    }
    catch
    {
        Write-Error $_.Exception.Message
    }
}