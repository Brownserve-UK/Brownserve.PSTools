function Add-VSCodeSpellChecker
{
    [CmdletBinding()]
    param
    (
        # The path to the repo where spellings should be added
        [Parameter(Mandatory = $true)]
        [string]
        $RepoPath,
        
        # The languages to support
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty]
        [string[]]
        $Language = @('en', 'en-GB')
    )
    
    begin
    {
        
    }
    
    process
    {
        

        $LanguageString = $Language -join ','
        try
        {
            # Don't pass in any arguments so we just get the default spellings
            $DefaultWords = Merge-VSCodeSpellings
            if (!$DefaultWords)
            {
                Write-Error 'Resulting spellings return was empty.'
            }
        }
        catch
        {
            throw "Failed to generate default spellings.`n$($_.Exception.Message)"
        }

        $SettingsHash = @{
            'cSpell.language' = $LanguageString
            'cSpell.words'    = $DefaultWords
        }

        # Add the extension as recommended for this repo
        try
        {
            Add-VSCodeRecommendedExtensions `
                -RepoPath $RepoPath `
                -Extension 'streetsidesoftware.code-spell-checker' `
                -ErrorAction 'Stop'
        }
        catch
        {
            throw "`n$($_.Exception.Message)"
        }

        # Add the spellings
        try
        {
            Update-VSCodeSettingsFile `
                -RepoPath $RepoPath `
                -Settings $SettingsHash `
                -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to update settings file.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        
    }
}