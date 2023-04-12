function ConvertFrom-URI
{
    [CmdletBinding()]
    param
    (
        # The URI to be converted
        [Parameter(
            Mandatory = $true,
            Position = 0, 
            ValueFromPipeline = $true, 
            ValueFromPipelineByPropertyName = $true)]
        [string]
        $InputObject    
    )
    
    begin
    {
        <#
            Yay, regex!
            I've been quite loose with the protocol so we can convert things like FTP/SMTP etc.
        #>
        $RegEx = '(?:(?<Protocol>\w*):\/\/)?(?:(?<Subdomain>[\w\.]+)?\.)?(?<Hostname>\w+)\.(?<Domain>\w+)\:?(?<Port>\d+)?(?:\/)(?<Path>.*)?'
        $Return = $null
    }
    
    process
    {
        if ($InputObject -match $RegEx)
        {
            $Hashtable = $Matches
            # Remove the key '0' which includes the entire regex match, and instead create a key called URI
            $Hashtable.Add('URI',$InputObject)
            $Hashtable.Remove(0)

            # Cast to a custom object
            $Return = [pscustomobject]$Hashtable
        }
    }
    
    end
    {
        if ($null -ne $Return)
        {
            return $Return
        }
    }
}