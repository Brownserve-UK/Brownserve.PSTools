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
            # ConvertFrom-Json -AsHashtable returns a case-sensitive hashtable in PS7,
            # so find the matching key case-insensitively.
            $MatchingKey = $Hashtable.Keys | Where-Object { $_ -ieq $Key } | Select-Object -First 1
            if (!$MatchingKey)
            {
                throw "Hashtable missing required key '$Key'"
            }
            $this.$Key = $Hashtable[$MatchingKey]
        }
    }
}