function Send-SlackNotification
{
    [CmdletBinding(
        DefaultParameterSetName = "Default"
    )]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1,
            ParameterSetName = "Default"
        )]
        [string]
        $Message,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2,
            ParameterSetName = "Default"
        )] 
        [string]
        $Webhook,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3,
            ParameterSetName = "Default"
        )]
        [string]
        $Channel,
    
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "Attachments"
        )]
        [string]
        [Alias('color')]
        $Colour, 
    
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "Attachments"
        )]
        [Alias('Push')]
        [string]
        $Title
    )

    if ($Title.Length -gt 75)
    {
        throw "Title must be 75 characters or less"
    }

    # Let's initialize an empty hash table that we'll use to build up the JSON payload
    # By default we set the "text" field to the $message variable so we always have something to send
    $SlackBody = @{
        text = $Message
        attachments = @(
            @{
                blocks = @(
                )
            }
        )
    }

    # If we've got any "attachments" then we need to make sure our message is set in the "attachments" section
    If ($Title -or $Colour)
    {
        # Make sure the "text param is blanked out" otherwise it really messes things up :(
        $SlackBody.text = ""

        # Add a fallback message to the attachment - this affects things like pop-up's/toasts
        $SlackBody.attachments[0].Add('fallback',$Title)

        $MessageObject = @{
            type = 'section'
            text = @{
                type = 'mrkdwn'
                text = $Message
            }
        }
    }

    if ($Title)
    {
        # Build up the "title" object
        $TitleObject = @{
            type = 'header'
            text = @{
                type = 'plain_text'
                text = $Title
                emoji = $true
            }
        }
        $SlackBody.attachments[0].blocks += $TitleObject
    }

    # We need to add the message object _after_ the title otherwise things look wrong 😂
    if ($MessageObject)
    {
        $SlackBody.attachments[0].blocks += $MessageObject
    }

    if ($Channel)
    {
        $SlackBody.Add('channel', $Channel)
    }

    if ($Colour)
    {
        if ($Colour -notmatch '#[0-9A-Fa-f]{6}')
        {
            throw "Colour must match the hexidecimal colour format. (e.g #FF1234)"
        }
        $SlackBody.attachments[0].Add('color',$Colour)
    }

    $ConvertedBody = $SlackBody | ConvertTo-Json -Depth 10

    Write-Debug $ConvertedBody

    try
    {
        invoke-RestMethod -Uri $Webhook -Method Post -Body $ConvertedBody -ErrorAction Stop
    }
    catch
    {
        Write-Error "Failed to send Slack notification.$($_.Exception.Message)"
    }
}
