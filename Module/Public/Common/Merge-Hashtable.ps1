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
                    # Because things can get confusing when using $_ notation I'm splitting things into variables to make tracking them easier
                    $InputObjectKeyName = $_.Key
                    $InputObjectValue = $_.Value
                    # First check if the key already exists in the base object
                    if ($Return.Keys -contains $InputObjectKeyName)
                    {
                        $BaseObjectValue = $Return.($InputObjectKeyName)
                        Write-Verbose "BaseObject already contains key of '$($InputObjectKeyName)'"
                        # If the key does already exist and we're doing a deep merge we need to see what content
                        # we are working with
                        if ($Deep)
                        {
                            if ($BaseObjectValue -is [array])
                            {
                                # Validate that the value we're bringing in is also an array
                                if ($InputObjectValue -is [array])
                                {
                                    # We make the concious choice to remove duplicate entries when merging arrays, I'm not sure
                                    # if this is standard behaviour when merging objects but we can could make this a parameter if we need to
                                    Write-Verbose "Key '$InputObjectKeyName' is an array, performing merge."
                                    Write-Debug "BaseObject values:`n$($BaseObjectValue -join "`n")`nInputObject values:`n$($InputObjectValue -join "`n")"
                                    $MergedArray = $BaseObjectValue + $InputObjectValue
                                    $Return.($InputObjectKeyName) = ($MergedArray | Select-Object -Unique)
                                }
                                else
                                {
                                    throw "Keys are of different type.`nBaseObject key is: '$($Return.($InputObjectKeyName).GetType().Name)'`nInputObject key is: '$($InputObjectKeyName.GetType().Name)'"
                                }
                            }
                            elseif ($BaseObjectValue -is [hashtable])
                            {
                                if ($InputObjectValue -is [hashtable])
                                {
                                    Write-Verbose "Key '$InputObjectKeyName' is a hashtable, performing merge."
                                    $Return.($InputObjectKeyName) = Merge-Hashtable `
                                        -BaseObject $Return.($InputObjectKeyName) `
                                        -InputObject $InputObjectValue `
                                        -Deep:$Deep `
                                        -ErrorAction 'Stop'
                                }
                                else
                                {
                                    throw "Keys are of different type.`nBaseObject key is: '$($Return.($InputObjectKeyName).GetType().Name)'`nInputObject key is: '$($InputObjectKeyName.GetType().Name)'"
                                }
                            }
                            else
                            {
                                Write-Debug "Overwriting key: $($InputObjectKeyName) with value: $($InputObjectValue)"
                                $Return.($InputObjectKeyName) = $InputObjectValue
                            }
                        }
                        else
                        {
                            Write-Debug "Overwriting key: $($InputObjectKeyName) with value: $($InputObjectValue)"
                            $Return.($InputObjectKeyName) = $InputObjectValue
                        }
                    }
                    else
                    {
                        Write-Debug "Adding new key: $($InputObjectKeyName) with value: $($InputObjectValue)"
                        $Return.Add($InputObjectKeyName, $InputObjectValue)
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