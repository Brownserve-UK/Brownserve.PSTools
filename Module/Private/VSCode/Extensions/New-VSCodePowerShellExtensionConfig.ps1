function New-VSCodePowerShellExtensionConfig
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
            'powershell.codeFormatting.autoCorrectAliases'       = $true
            'powershell.codeFormatting.pipelineIndentationStyle' = 'IncreaseIndentationAfterEveryPipeline'
            'powershell.codeFormatting.preset'                   = 'Allman'
            'powershell.codeFormatting.useCorrectCasing'         = $true
            'powershell.helpCompletion'                          = 'Disabled'
            'powershell.codeFormatting.trimWhitespaceAroundPipe' = $true
            'powershell.codeFormatting.useConstantStrings'       = $true
        }
        $ExtensionID = 'ms-vscode.powershell'
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