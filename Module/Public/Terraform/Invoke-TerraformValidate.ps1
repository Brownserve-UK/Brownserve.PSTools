function Invoke-TerraformValidate
{
    [CmdletBinding()]
    param
    (
        # The path to the Terraform Configuration to validate
        [Parameter(
            Mandatory = $false,
            Position = 0
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
    $ValidateArgs = @('validate')
    if (-not $EnableColor)
    {
        $ValidateArgs += '-no-color'
    }
    try
    {
        Start-SilentProcess `
            -FilePath $TerraformPath `
            -ArgumentList $ValidateArgs `
            -WorkingDirectory $TerraformConfigPath
    }
    catch
    {
        Write-Error $_.Exception.Message
    }
}