function Get-VaultSecret
{
    [CmdletBinding()]
    param
    (
        # The path to the secret
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [Alias('Path')]
        [string]
        $SecretPath
    )
    try
    {
        Write-Verbose "Attempting to read $SecretPath from vault"
        $Secret = Start-SilentProcess `
            -FilePath 'vault' `
            -ArgumentList "read -format=json $SecretPath" `
            -PassThru
        # Now we've got the secret clean up the local file we've got hanging around
        Remove-Item $Secret.StdOutFilePath -Force
        $SecretJSON = $Secret | Select-Object -ExpandProperty OutputContent
    }
    catch
    {
        throw "Failed to fetch vault secret $SecretPath.`n$($_.Exception.Message)"
    }

    if (!$SecretJSON)
    {
        throw "Vault returned an empty secret for $SecretPath"
    }

    try
    {
        $ConvertedSecret = $SecretJSON | 
            ConvertFrom-Json | 
                Select-Object -ExpandProperty data
        Return $ConvertedSecret
    }
    catch
    {
        Write-Error "Failed to convert secret $SecretPath from JSON.`n$($_.Exception.Message)"
    }
}