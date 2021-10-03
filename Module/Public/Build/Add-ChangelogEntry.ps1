function Add-ChangelogEntry
{
    [CmdletBinding()]
    param
    (
        # The path to the changelog file
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string]
        $ChangelogPath,

        # Allows us to pipe in an object from Read-Changelog so we don't have to process it again
        [Parameter(
            DontShow,
            ValueFromPipeline = $true
        )]
        [pscustomobject]
        $ChangelogObject,

        # The content to be inserted into the changelog
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [string]
        $NewContent
    )
    if (!(Test-Path $ChangelogPath))
    {
        throw "$ChangelogPath does not appear to be a valid path to a changelog"
    }

    # If we haven't piped in an object then get our information
    if (!$ChangelogObject)
    {
        Write-Verbose "Parsing changelog information"
        try
        {
            $ChangelogObject = Read-Changelog -ChangelogPath $ChangelogPath
        }
        catch
        {
            throw "Failed to get current changelog information.`n$($_.Exception.Message)"
        }
    }
    $ChangelogContent = $ChangelogObject.Content
    $InsertLine = $ChangelogObject.InsertLine

    # Split the array of text...
    try
    {
        Write-Verbose "Splitting text to insert the new values"
        $Text1 = $ChangelogContent[0..$InsertLine]
        $Text2 = $ChangelogContent[$InsertLine..$ChangelogContent.Length]
        # Split our text by newline to get a nice array to merge with the others
        $NewText = $NewContent -split "`n"
        $NewText = $Text1 + $NewContent + $Text2
    }
    catch
    {
        throw "Failed to rebuild changelog.`n$($_.Exception.Message)"
    }

    # Set the content of the changelog
    try
    {
        Set-Content $ChangelogPath -Value $NewText
    }
    catch
    {
        Write-Error "Failed to set changelog text.$($_.Exception.Message)"
    }
}