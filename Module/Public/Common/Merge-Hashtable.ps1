function Merge-Hashtable
{
    [CmdletBinding()]
    param
    (
        # The primary object
        [Parameter(Mandatory = $true, Position = 0)]
        [hashtable]
        $BaseObject,
        
        # The secondary object
        [Parameter(Mandatory = $true, Position = 1)]
        [hashtable[]]
        $InputObject
    )
    
    begin
    {
        
    }
    
    process
    {
        $Return = $BaseObject
        # We may have multiple input objects, iterate over each
        try
        {
            $InputObject | ForEach-Object {
                $_.GetEnumerator() | ForEach-Object {
                    if ($Return.Keys -contains $_.Key)
                    {
                        Write-Debug "Overwriting key: $($_.Key) with value: $($_.Value)"
                        $Return.($_.Key) = $_.Value
                    }
                    else
                    {
                        Write-Debug "Adding key: $($_.Key) with value: $($_.Value)"
                        $Return.Add($_.Key, $_.Value)
                    }
                }
            }
        }
        catch
        {
            throw "Failed to merge hashtable's.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        if ($Return)
        {
            return $Return
        }
        else
        {
            return $null
        }
    }
}