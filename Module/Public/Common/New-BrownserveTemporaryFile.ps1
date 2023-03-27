function New-BrownserveTemporaryFile
{
    [CmdletBinding(DefaultParameterSetName = 'default')]
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

        # The content of the file to be created
        [Parameter(Mandatory = $false, ParameterSetName = 'Content')]
        [string]
        $Content,

        # Skips creation of the temporary file in case some other process will do that
        [Parameter(ParameterSetName = 'Skip')]
        [switch]
        $SkipCreation
    )
    
    begin
    {
        # If the path hasn't been provided then we use whatever temp location we want
        if (!$FilePath)
        {
            $FilePath = $script:BrownserveTempLocation
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
                $Path = Join-Path $PathCheck "$($_)$($FileExtension)"
                if ($SkipCreation -ne $true)
                {
                    $NewItemParams = @{
                        ItemType    = 'File'
                        ErrorAction = 'Stop'
                        Path        = $Path
                    }
                    if ($Content)
                    {
                        $NewItemParams.Add('Value', $Content)
                    }
                    $Return += New-Item @NewItemParams | Convert-Path
                }
                else
                {
                    $Return += $Path
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