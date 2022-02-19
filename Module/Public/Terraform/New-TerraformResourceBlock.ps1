function New-TerraformResourceBlack
{
    [CmdletBinding()]
    param
    (
        # The resource type to create
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $ResourceType,

        # The name of the resource
        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $ResourceName,

        # The arguments for the resource
        [Parameter(Mandatory = $true, Position = 2)]
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
                $ResourceBlock += "    $($_.Name) = $($_.Value | ConvertTo-TerraformObject)`n"
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