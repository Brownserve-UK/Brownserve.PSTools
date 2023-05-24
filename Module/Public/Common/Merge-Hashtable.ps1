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
        $InputObject,

        # If set will attempt to do a deep merge
        [Parameter(Mandatory = $false)]
        [switch]
        $Deep
    )
    
    begin
    {
        $Return = $null
    }
    
    process
    {
        # Set the return to be the base object
        $Return = $BaseObject.Clone()
        # We may have multiple input objects, iterate over each
        try
        {
            $InputObject | ForEach-Object {
                $_.GetEnumerator() | ForEach-Object {
                    # First check if the key already exists in the base object
                    if ($Return.Keys -contains $_.Key)
                    {
                        Write-Debug "BaseObject already contains key of '$($_.Key)'"
                        # If the key does already exist and we're doing a deep merge we need to see what content
                        # we are working with
                        if ($Deep)
                        {
                            # Because we're using a switch statement which will overwrite our $_ object we need to set a few variable first
                            $BaseObjectValue = $Return.($_.Key)
                            $InputObjectKey = $_.Key
                            $InputObjectValue = $_.Value
                            if ($BaseObjectValue -is [array])
                            {
                                Write-Debug "Key '$InputObjectKey' is an array"
                                # Validate that the value we're bringing in is also an array
                                if ($InputObjectValue -is [array])
                                {
                                    # We make the concious choice to remove duplicate entries when merging arrays, I'm not sure
                                    # if this is standard behaviour when merging objects but we can could make this a parameter if we need to
                                    Write-Debug "Merging array: $InputObjectKey with values:$($BaseObjectValue -join "`n")`n$($InputObjectValue -join "`n")"
                                    $MergedArray = $BaseObjectValue + $InputObjectValue
                                    Write-Debug "$MergedArray"
                                    $Return.($InputObjectKey) = ($MergedArray | Select-Object -Unique)
                                }
                                else
                                {
                                    throw "Keys are of different type.`nBaseObject key is: '$($Return.($InputObjectKey).GetType().Name)'`nInputObject key is: '$($InputObjectKey.GetType().Name)'"
                                }
                            }
                            elseif ($BaseObjectValue -is [hashtable])
                            {
                                if ($InputObjectValue -is [hashtable])
                                {
                                    Write-Debug "Merging hashtable: $($InputObjectKey)"
                                    $Return.($InputObjectKey) = Merge-Hashtable `
                                        -BaseObject $Return.($InputObjectKey) `
                                        -InputObject $InputObjectValue `
                                        -Deep:$Deep `
                                        -ErrorAction 'Stop'
                                }
                                else
                                {
                                    throw "Keys are of different type.`nBaseObject key is: '$($Return.($InputObjectKey).GetType().Name)'`nInputObject key is: '$($InputObjectKey.GetType().Name)'"
                                }
                            }
                            else
                            {
                                Write-Debug "$InputObjectKey is $($_.GetType().Name)"
                                Write-Debug "Overwriting key: $($InputObjectKey) with value: $($InputObjectValue)"
                                $Return.($InputObjectKey) = $InputObjectValue
                            }
                        }
                        else
                        {
                            Write-Debug "Overwriting key: $($_.Key) with value: $($_.Value)"
                            $Return.($_.Key) = $_.Value
                        }
                    }
                    else
                    {
                        Write-Debug "Adding new key: $($_.Key) with value: $($_.Value)"
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