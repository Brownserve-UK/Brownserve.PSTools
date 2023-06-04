function ConvertTo-HTTPSRepoURL
{
    [CmdletBinding()]
    param
    (
        # The ssh object to be converted
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [GitURI[]]
        $InputObject    
    )
    
    begin
    {
        $Return = @()
    }
    
    process
    {
        $InputObject | ForEach-Object {
            if ($_.URI -match '^git@(?<host>.*):(?<owner>.*)\/(?<repo>.*).git$')
            {   
                $ConvertedURI = "https://$($Matches['host'])/$($Matches['owner'])/$($Matches['repo'])"
                $Return += $ConvertedURI
            }
            else
            {
                throw "Object '$($_.URI)' does not appear to be a valid repo URI."
            }
        }
    }
    
    end
    {
        if ($Return.Count -gt 0)
        {
            return $Return
        }
        else
        {
            return $null
        }
    }
}