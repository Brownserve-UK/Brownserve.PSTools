function Invoke-TerraformInit
{
    [CmdletBinding()]
    param
    (
        # The path to the Terraform config to init
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $TerraformConfigPath = $PWD,

        # The Path to the Terraform binary
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $TerraformPath = 'terraform',

        # Whether or not to enable color output, defaults to false so as not to break CI/CD tools
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [bool]
        $EnableColor = $false
    )
    $InitArgs = @('init')
    if (-not $EnableColor)
    {
        $InitArgs += '-no-color'
    }
    try
    {
        $InitParams = @{
            FilePath = $TerraformPath
            ArgumentList = $InitArgs
            WorkingDirectory = $TerraformConfigPath
            SuppressOutput = $true
        }
        if ($VerbosePreference -eq 'Continue')
        {
            $InitParams.Remove('SuppressOutput')
        }
        Invoke-NativeCommand @InitParams
    }
    catch
    {
        Write-Error $_.Exception.Message
    }
}