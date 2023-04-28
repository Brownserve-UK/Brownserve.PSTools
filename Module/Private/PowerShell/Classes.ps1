class BrownservePowerShellModule
{
    [string]$Name
    [string]$Description
    [guid]$GUID
    [string[]]$Tags

    BrownservePowerShellModule([hashtable]$Hashtable)
    {
        $RequiredKeys = @('name','description','guid','tags')
        foreach ($Key in $RequiredKeys)
        {
            if (!$Hashtable.$Key)
            {
                "Hashtable missing key '$Key'"
            }
            $this.$Key = $Hashtable.$Key
        }
    }
}