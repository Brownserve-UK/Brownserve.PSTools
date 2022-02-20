function New-TerraformResourceBlock
{
    [CmdletBinding()]
    param
    (
        # The resource type to create
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [string]
        $ResourceType,

        # The name of the resource
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [string]
        $ResourceName,

        # The arguments for the resource
        [Parameter(Mandatory = $true, Position = 2, ValueFromPipelineByPropertyName = $true)]
        [pscustomobject]
        $ResourceArgs
    )
    
    begin
    {
        
    }
    
    process
    {
        try
        {
            $ResourceBlock = "resource `"$ResourceType`" `"$ResourceName`" {`n"
            $ResourceArgs.PSObject.Properties | ForEach-Object {
                if ($_.Value -is [hashtable])
                {
                    $ResourceBlock += "`t$($_.Name) $(ConvertTo-TerraformObject -Object $_.Value)`n"
                }
                else
                {
                    $ResourceBlock += "`t$($_.Name) = $(ConvertTo-TerraformObject -Object $_.Value)`n"
                }
            }
            $ResourceBlock += "}`n"
        }
        catch
        {
            throw $_.Exception.Message
        }
    }
    
    end
    {
        if ($ResourceBlock)
        {
            Return $ResourceBlock
        }
        else
        {
            Return $null
        }
    }
}