function Set-LineEndings
{
    [CmdletBinding()]
    param
    (
        # The path to the file to be converted.
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string[]]
        $Path,

        # The type of line ending to use.
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [ValidateSet('CRLF', 'LF')]
        [string]
        $LineEnding = 'LF'
    )
    begin
    {

    }
    process
    {
        foreach ($file in $Path)
        {
            switch ($LineEnding)
            {
                'CRLF'
                {
                    $LineEndingToUse = "`r`n"
                }
                'LF'
                {
                    $LineEndingToUse = "`n"
                }
                Default {}
            }
            try
            {
                $NewContent = ''
                # It seems reading in the file without the -Raw parameter will remove the line endings.
                $Content = Get-Content -Path $file -ErrorAction 'Stop'
                $Content | ForEach-Object {
                    $NewContent += $_ + $LineEndingToUse
                }
                Write-Verbose "New content:`n$NewContent"
            }
            catch
            {
                throw "Failed to replace line endings in file '$file'. `n$($_.Exception.Message)"
            }

            try
            {
                Set-Content -Path $file -Value $NewContent -ErrorAction 'Stop' -NoNewline
            }
            catch
            {
                throw "Failed to write new content to file '$file'. `n$($_.Exception.Message)"
            }
        }
    }
    end
    {

    }
}