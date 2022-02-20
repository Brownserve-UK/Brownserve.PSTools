function ConvertTo-TerraformObject
{
    [CmdletBinding()]
    param
    (
        # The object to be converted
        # N.B - don't accept pipeline input here as it unfolds arrays!
        [Parameter(Mandatory = $true, Position = 0)]
        $Object
    )
    
    begin
    {
        
    }
    
    process
    {
        Write-Debug "$($Object.GetType().Name)"
        switch -Regex ($Object.GetType().Name)
        {
            'String'
            {
                Write-Debug 'Converting to string'
                # If the object is a string wrap it in quotes, unless it's a variable, local or a resource (rough regex match for this)
                if (($Object -match '^var.') -or ($Object -match '^local.') -or ($Object -match '^(?:.*)\.(?:.*)\.(?:.*)$'))
                {
                    $Return = $Object
                }
                else
                {
                    $Return = "`"$Object`""
                }
            }
            'Object'
            {
                try
                {
                    Write-Debug 'Converting to array'
                    # Got through the array and convert each item within it
                    $ConvertedObjects = @()
                    $ConvertedObjects += $Object | ForEach-Object { ConvertTo-TerraformObject $_ }
                    $Return = "[$($ConvertedObjects -join ', ')]"
                }
                catch
                {
                    Write-Error $_.Exception.Message
                }
            }
            'Hashtable'
            {
                Write-Debug 'Converting to hash'
                # Go through each value and convert it
                try
                {
                    $ConvertedHash = "{`n"
                    $Object.GetEnumerator() | ForEach-Object {
                        $Key = $_.Key
                        $Value = ConvertTo-TerraformObject $_.Value
                        if ($_.Value -is [Hashtable])
                        {
                            $ConvertedHash += "`t$Key $Value`n"
                        }
                        else
                        {
                            $ConvertedHash += "`t$Key = $Value`n"
                        }
                    }
                    $ConvertedHash += "`t}"
                    $Return = $ConvertedHash
                }
                catch
                {
                    Write-Error $_.Exception.Message
                }
            }
            'Boolean'
            {
                Write-Debug 'Converting to boolean'
                # Convert to terraform boolean
                $Return = $Object -eq $true ? 'true' : 'false'
            }
            'Int'
            {
                Write-Debug 'Converting to int'
                # Convert to terraform int (just return as is)
                $Return = $Object
            }
            Default
            {
                Write-Error "Unsupported type: $($Object.GetType().Name).`nValid types are string, array, hashtable."
            }
        }
    }
    
    end
    {
        if ($Return)
        {
            Return $Return
        }
        else
        {
            Return $null
        }
    }
}