function Add-ModuleHelp
{
    [CmdletBinding()]
    param
    (
        # The path to the directory where the module lives
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $ModuleDirectory,

        # The language that the help is written in
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [string]
        $HelpLanguage = 'en-US',

        # The path to the documentation that will generate the help file
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $DocumentationPath
    )
    
    begin
    {
        
    }
    
    process
    {
        try
        {
            $ModuleDirCheck = Get-Item $ModuleDirectory -ErrorAction 'Stop' | Where-Object { $_.PSIsContainer -eq $true }
            if (!$ModuleDirCheck)
            {
                throw 'ModuleDirectory does not appear to be a valid directory'
            }
            $ModuleDirIsModuleCheck = Get-ChildItem $ModuleDirectory -Recurse | Where-Object {($_.Name -like '*.psm1') -or {$_.Name -like '*.psd1'}}
            if (!$ModuleDirIsModuleCheck)
            {
                throw "No valid modules could be found in '$ModuleDirectory'"
            }
            $DocDirCheck = Get-Item $DocumentationPath -ErrorAction 'Stop' | Where-Object { $_.PSIsContainer -eq $true }
            if (!$DocDirCheck)
            {
                throw 'DocumentationPath does not appear to be a valid directory'
            }
        }
        catch
        {
            throw $_.Exception.Message
        }

        $HelpPath = Join-Path $ModuleDirectory $HelpLanguage

        if (!(Test-Path $HelpPath))
        {
            try
            {
                New-Item $HelpPath -ItemType Directory -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to created $HelpPath.`n$($_.Exception.Message)"
            }
        }

        try
        {
            New-ExternalHelp `
                -Path $DocumentationPath `
                -OutputPath $HelpPath `
                -Force `
                -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to generate MALM help.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        
    }
}