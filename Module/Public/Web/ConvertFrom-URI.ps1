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
        [string[]]
        $InputObject,

        # Returns the object as a Hashtable instead of a custom object
        [Parameter(Mandatory = $false)]
        [switch]
        $AsHashtable
    )
    
    begin
    {
        <#
            Yay, regex!
            I've been quite loose with the protocol so we can convert things like FTP/SMTP etc.
        #>
        $RegEx = '(?:(?<Protocol>\w*):\/\/)?(?:(?<Subdomain>[\w\.]+)?\.)?(?<Hostname>\w+)\.(?<Domain>\w+)\:?(?<Port>\d+)?(?:\/)?(?<Path>.*)?'
        $Return = @()
    }
    
    process
    {
        $InputObject | ForEach-Object {
            if ($_ -match $RegEx)
            {
                $Hashtable = $Matches
                # Remove the key '0' which includes the entire regex match, and instead create a key called URI
                $Hashtable.Add('URI', $InputObject)
                $Hashtable.Remove(0)
                # Somehow we're getting an empty string returned from the path regex, not sure how but for now just filter it out
                if ('' -eq $Hashtable.Path)
                {
                    $Hashtable.Remove('Path')
                }

                if ($AsHashtable)
                {
                    $Return += $AsHashtable
                }
                else
                {
                    # Cast to a custom object
                    $Return += [pscustomobject]$Hashtable
                }
            }
        }
    }
    
    end
    {
        if ($Return -ne @())
        {
            return $Return
        }
    }
}