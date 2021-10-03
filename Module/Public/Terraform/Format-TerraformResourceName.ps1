function Format-TerraformResourceName
{
    [CmdletBinding()]
    param
    (
        # The resource name to be formatted
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string]
        $ResourceName,

        # The characters that are valid (takes the form of a RegEx pattern)
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]
        $ValidCharacters = '[^0-9a-zA-Z\-_]+'
    )
    $SanitizedName = $ResourceName -replace $ValidCharacters,''
    # Terraform breaks if a resource name starts with a digit, fix that up here.
    if ($SanitizedName -match '^\d')
    {
        Write-Verbose "Resource: '$SanitizedName' starts with a digit, prefixing with 'N'"
        $SanitizedName = 'N' + $SanitizedName
    }
    Return $SanitizedName
}