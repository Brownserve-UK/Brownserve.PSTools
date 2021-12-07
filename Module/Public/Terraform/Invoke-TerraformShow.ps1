function Invoke-TerraformShow
{
    [CmdletBinding()]
    param
    (
        # The path to the Terraform configuration (ignored if InputFile is set)
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
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

        # An optional path to either a Terraform plan output file or Terraform state file, if none is provided the default state is used
        [Parameter(Mandatory = $false,
            Position = 1,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias(
            "OutputPath",
            "TerraformPlanPath",
            "TerraformStatePath"
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $InputFile
    )
    $ShowArgs = @('show -json')
    # If we've got an InputFile, validate it and add to the show command argument list
    if ($InputFile)
    {
        Write-Verbose "Checking input file is valid"
        try
        {
            $InputFileAbsolutePath = Get-Item $InputFile | Convert-Path
        }
        catch
        {
            throw $_.Exception.Message
        }
        $ShowArgs += $InputFileAbsolutePath
    }

    # Get the output from Terraform show
    try
    {
        $ShowParams = @{
            FilePath = $TerraformPath
            ArgumentList = $ShowArgs
            WorkingDirectory = $TerraformConfigPath
            PassThru = $true
            SuppressOutput = $true
        }
        if ($VerbosePreference -eq 'Continue')
        {
            $ShowParams.Remove('SuppressOutput')
        }
        $ShowOutput = Invoke-NativeCommand @ShowParams | Select-Object -ExpandProperty OutputContent
    }
    catch
    {
        throw "Terraform show has failed.`n$($_.Exception.Message)"
    }

    # Convert the output from JSON
    try
    {
        $ConvertedOutput = $ShowOutput | ConvertFrom-Json
    }
    catch
    {
        Write-Error "Failed to convert terraform output to JSON.`n$($_.Exception.Message)"
    }
    Return $ConvertedOutput
}