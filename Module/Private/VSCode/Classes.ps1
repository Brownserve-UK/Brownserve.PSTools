class BrownserveVSCodeExtension
{
    [string]$ExtensionID
    [hashtable]$Settings

    BrownserveVSCodeExtension([hashtable]$Hash)
    {
        $this.ExtensionID = $Hash.ExtensionID
        $this.Settings = $Hash.Settings
    }

    BrownserveVSCodeExtension([string]$ExtensionID, [hashtable]$Hash)
    {
        $this.ExtensionID = $ExtensionID
        $this.Settings = $Hash
    }
}