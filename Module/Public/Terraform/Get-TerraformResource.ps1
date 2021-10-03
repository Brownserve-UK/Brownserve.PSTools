function Get-TerraformResource
{
    [CmdletBinding()]
    param
    (
        # The resource type as defined in the Terraform modules documentation
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string]
        $ResourceType,

        # The resource name
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]
        $ResourceName,
        
        # Specifies a path to look for the resource block in.
        [Parameter(Mandatory = $false,
            Position = 2,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string]
        $TerraformConfigPath = $PWD
    )
    
    # Remove quotations from resource types, we define them in our regex.
    $ResourceType = $ResourceType -replace '"', ''
    $ResourceName = $ResourceName -replace '"', ''
    
    # Escape for our regex search below
    $ResourceType = $([Regex]::Escape($ResourceType))
    $ResourceName = $([Regex]::Escape($ResourceName))

    try
    {
        $AbsoluteTerraformConfigPath = Get-Item $TerraformConfigPath
    }
    catch
    {
        "$TerraformConfigPath does not appear to be valid.`n$($_.Exception.Message)"
    }
    
    # If we've passed in a directory then get any .tf files from within.
    if ($AbsoluteTerraformConfigPath.PSIsContainer)
    {
        try
        {
            $TerraformConfig = Get-ChildItem $AbsoluteTerraformConfigPath -Recurse -Filter "*.tf"
        }
        catch
        {
            throw "Failed to get nested Terraform config.`n$($_.Exception.Message)"
        }
        if (!$TerraformConfig)
        {
            throw "$TerraformConfigPath does not appear to contain any Terraform files"
        }
    }
    else
    {
        if ($AbsoluteTerraformConfigPath.Name -notlike "*.tf")
        {
            throw "$TerraformConfigPath does not appear to be a valid Terraform file."
        }
        $TerraformConfig = $AbsoluteTerraformConfigPath
    }

    # The below regex is the result of 3 hours of my life that I will never get back
    $Regex = "(resource \`"$ResourceType\`" \`"$ResourceName\`" {(?>[^{}]+|{(?<curly>)|}(?<-curly>))*(?(curly)(?!))})"

    $TerraformConfig | ForEach-Object {
            
        try
        {
            if ((Get-Content $_ -Raw) -match $Regex)
            {
                Return $Matches[0]
            }
        }
        catch
        {
            Write-Error "Failed to parse Terraform config $_.`n$($_.Exception.Message)"
        }
    }
}