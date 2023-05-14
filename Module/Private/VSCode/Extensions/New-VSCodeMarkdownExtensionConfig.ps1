function New-VSCodeMarkdownExtensionConfig
{
    [CmdletBinding()]
    param
    (
        
    )
    
    begin
    {
        
    }
    
    process
    {
        $SettingsHash = @{
            'markdown.extension.toc.omittedFromToc' = @{
                'README.md' = @('# Overview')
            }
            'markdown.extension.toc.updateOnSave'   = $false
        }
        $ExtensionID = 'yzhang.markdown-all-in-one'
        $Return = [BrownserveVSCodeExtension]@{
            ExtensionID = $ExtensionID
            Settings = $SettingsHash
        }
    }
    
    end
    {
        if ($Return)
        {
            return $Return
        }
    }
}