function New-BrownserveTemporaryFile
{
    [CmdletBinding()]
    param
    (
        # The name of the file to create
        [Parameter(Mandatory = $false)]
        [string[]]
        $FileName,
        
        # The file extension to use
        [Parameter(Mandatory = $false)]
        [string]
        $FileExtension = '.tmp',

        # The path to where the file should be stored
        [Parameter(Mandatory = $false)]
        [string]
        $FilePath,

        # Skips creation of the temporary file in case some other process will do that
        [Parameter()]
        [switch]
        $SkipCreation
    )
    
    begin
    {
        # If the path hasn't been provided then we can work it out based on whether or not our special variable is set
        if (!$FilePath)
        {
            if ($global:RepoTempDirectory)
            {
                $FilePath = $global:RepoTempDirectory
            }
            else
            {
                $FilePath = (Get-PSDrive Temp).Root
            }
        }
        if ($FileExtension -notmatch '^\.')
        {
            $FileExtension = ".$($FileExtension)"
        }
        $Return = @()
    }
    
    process
    {
        try
        {
            $PathCheck = Get-Item $FilePath -Force -ErrorAction 'Stop' 
        }
        catch
        {
            throw "'$FilePath' does not appear to be a valid directory"
        }
        if ($PathCheck.PSIsContainer -ne $true)
        {
            throw "'$FilePath' must be a directory"
        }
        if (!$FileName)
        {
            $Chars = 'a'..'z' + 'A'..'Z' + '0'..'9'

            $FileName = -join (0..5 | ForEach-Object { $Chars | Get-Random })
        }
        $FileName | ForEach-Object {
            try
            {
                $Name = "$($_)$($FileExtension)"
                if ($SkipCreation -ne $true)
                {
                    $Return += New-Item (Join-Path $PathCheck $Name) -ItemType File -ErrorAction 'Stop' | Convert-Path
                }
                else
                {
                    $Return += Join-Path $PathCheck $Name
                }
            }
            catch
            {
                throw "Failed to generate new temporary file.`n$($_.Exception.Message)"
            }
        }
    }
    
    end
    {
        if ($Return -ne @())
        {
            return $Return
        }
        else
        {
            return $null
        }
    }
}