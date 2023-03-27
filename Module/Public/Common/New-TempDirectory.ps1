function New-TempDirectory
{
    [CmdletBinding()]
    param
    ()
    
    begin
    {}
    
    process
    {
        # It's EXTREMELY unlikely but just to be safe we'll make sure we get a directory name that doesn't already exist
        $Count = 0
        try
        {
            $TempDirName = ( -join ((0x30..0x39) + ( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 8 | ForEach-Object { [char]$_ }))
            $TempDirPath = Join-Path $script:BrownserveTempLocation $TempDirName
            while ((Test-Path $TempDirPath) -and $Count -lt 10) 
            {
                Write-Verbose "Temp directory $TempDirPath already exists, choosing another name."
                $Count = $Count + 1
                $TempDirName = ( -join ((0x30..0x39) + ( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count 8 | ForEach-Object { [char]$_ }))
                $TempDirPath = Join-Path $script:BrownserveTempLocation $TempDirName
            }
            if ($Count -ge 10)
            {
                throw "Unique name attempts exceeded."
            }
            $TempDirectory = New-Item $TempDirPath -ItemType Directory -Force
        }
        catch
        {
            throw "Failed to create temp directory.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        if ($TempDirectory)
        {
            Return $TempDirectory
        }
    }
}