class GitIgnore
{
    [string[]]$Item
    [string]$Comment

    GitIgnore([hashtable]$Hashtable)
    {
        if (!$Hashtable.Item)
        {
            throw "Hashtable does not contain a key named 'Item'"
        }
        $this.Item = $Hashtable.Item
        if ($Hashtable.Comment)
        {
            # Try to ensure every line starts with the pound symbol
            $LocalComment = $Hashtable.Comment -split "`n"
            $SanitizedComment = ""
            $LocalComment | ForEach-Object {
                if ($_ -notmatch '^\#')
                {
                    $SanitizedComment += "# $_"
                }
                else
                {
                    $SanitizedComment += $_
                }
                if ($_ -notmatch $LocalComment[-1])
                {
                    $SanitizedComment += "`n"
                }
            }
            $this.Comment = $SanitizedComment
        }
    }

    GitIgnore([string]$Item)
    {
        $this.Item = $Item
    }

    GitIgnore([string]$Item, [string]$Comment)
    {
        $this.Item = $Item
        # Try to ensure every line starts with the pound symbol
        $LocalComment = $Comment -split "`n"
        $SanitizedComment = ""
        $LocalComment | ForEach-Object {
            if ($_ -notmatch '^\#')
            {
                $SanitizedComment += "# $_"
            }
            else
            {
                $SanitizedComment += $_
            }
            if ($_ -notmatch $LocalComment[-1])
            {
                $SanitizedComment += "`n"
            }
        }
        $this.Comment = $SanitizedComment
    }
}