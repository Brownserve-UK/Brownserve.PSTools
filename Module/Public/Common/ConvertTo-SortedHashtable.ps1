function ConvertTo-SortedHashtable
{
    [CmdletBinding()]
    param
    (
        # The hashtable to sort
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true)]
        [hashtable[]]
        $InputObject
    )
    
    begin
    {
        $Return = @()
    }
    
    process
    {
        # Create an empty ordered list
        $OrderedList = [ordered]@{}
        # Create an array of the sorted keys
        $InputObject | ForEach-Object{
            $SortedArray = $_.GetEnumerator() | Sort-Object -Property Name
        }
        # Add sorted keys back to the ordered dictionary to re-establish our hashtable
        $SortedArray | ForEach-Object {
            $OrderedList.Add($_.Key,$_.Value)
        }
        $Return += $OrderedList
    }
    
    end
    {
        switch ($Return.Count)
        {
            0
            {
                return $null
            }
            1
            {
                # Preserve the object type on return
                return $Return[0]
            }
            Default
            {
                return $Return
            }
        }
    }
}