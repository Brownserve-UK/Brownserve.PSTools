function ConvertTo-TerraformObject
{
    [CmdletBinding()]
    param
    (
        # The object to be converted
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        $Object
    )
    
    begin
    {
        
    }
    
    process
    {
        switch ($Object.GetType().Name)
        {
            'String'
            {
                Write-Verbose 'Converting to string'
                # If the object is a string wrap it in quotes, unless it's a variable, local or a resource (rough regex match for this)
                if (($Object -like 'var.*') -or ($Object -like 'local.') -or ($Object -match '^(?:.*)\.(?:.*)\.(?:.*)$'))
                {
                    $Return = $Object
                }
                else
                {
                    $Return = "`"$Object`""
                }
            }
            'Object[]'
            {
                try
                {
                    Write-Verbose 'Converting to array'
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
                Write-Verbose 'Converting to hash'
                # Go through each value and convert it
                try
                {
                    $ConvertedHash = "{`n"
                    $Object.GetEnumerator() | ForEach-Object {
                        $Key = $_.Key
                        $Value = ConvertTo-TerraformObject $_.Value
                        $ConvertedHash += "`t$Key = $Value`n"
                    }
                    $ConvertedHash += "}"
                    $Return = $ConvertedHash
                }
                catch
                {
                    Write-Error $_.Exception.Message
                }
            }
            'Boolean'
            {
                Write-Verbose 'Converting to boolean'
                # Convert to terraform boolean
                $Return = $Object -eq $true ? 'true' : 'false'
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