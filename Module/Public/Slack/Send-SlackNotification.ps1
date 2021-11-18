function Send-SlackNotification
{
    [CmdletBinding(
        DefaultParameterSetName = "Default"
    )]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string]
        $Message,

        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )] 
        [string]
        $Webhook,

        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 3
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
        $Title,

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = "Attachments"
        )]
        [array]
        $SubBlocks
    )

    if ($Title.Length -gt 75)
    {
        throw "Title must be 75 characters or less"
    }

    # Let's initialize an empty hash table that we'll use to build up the JSON payload
    # By default we set the "text" field to the $message variable so we always have something to send
    $SlackBody = @{
        text        = $Message
        attachments = @(
            @{
                blocks = @(
                )
            }
        )
    }

    if ($Channel)
    {
        $SlackBody.Add('channel', $Channel)
    }

    if ($Colour)
    {
        if ($Colour -notmatch '#[0-9A-Fa-f]{6}')
        {
            throw "Colour must match the hexadecimal colour format. (e.g #FF1234)"
        }
        $SlackBody.attachments[0].Add('color', $Colour)
    }

    # If we've got any "attachments" then we need to make sure our message is set in the "attachments" section
    If ($Title -or $Colour)
    {
        # Make sure the "text" param is blanked out otherwise it really messes things up :(
        $SlackBody.text = ""

        # Add a fallback message to the attachment - this affects things like pop-up's/toasts
        $SlackBody.attachments[0].Add('fallback', $Title)

        # If the message is longer than the max length we'll need to send it as raw text to the attachment instead.
        if ($Message.Length -lt 3000)
        {
            # Build up a message object, but add it later
            $MessageObject = @{
                type = 'section'
                text = @{
                    type = 'mrkdwn'
                    text = $Message
                }
            }
        }
        else
        {
            Write-Verbose "Message over 3000 characters, falling back to legacy method"
            $SlackBody.attachments[0].Add('text', $Message)
            # We need to tell Slack that the text is a "mrkdwn" type
            $SlackBody.attachments[0].Add('mrkdwn_in', @('text'))
        }
    }

    if ($Title)
    {
        # If we're using the "attachments" for our main text then we need to add the title to the attachment instead of the blocks
        if ($SlackBody.attachments[0].text)
        {
            $SlackBody.attachments[0].Add('title', $Title)
        }
        else
        {
            # Build up the "title" object and add it to the body
            $TitleObject = @{
                type = 'header'
                text = @{
                    type  = 'plain_text'
                    text  = $Title
                    emoji = $true
                }
            }
            $SlackBody.attachments[0].blocks += $TitleObject
        }
    }

    # We need to add the message object _after_ the title otherwise things look wrong 😂
    if ($MessageObject)
    {
        $SlackBody.attachments[0].blocks += $MessageObject
    }

    # If we've got any sub-blocks then add them at the end of the message
    if ($SubBlocks)
    {
        $SubBlocks | ForEach-Object {
            $SlackBody.attachments[0].blocks += $_
        }
    }

    # Convert with a reasonable depth, we have a lot of nested objects!
    $ConvertedBody = $SlackBody | ConvertTo-Json -Depth 10

    Write-Debug $ConvertedBody

    try
    {
        Invoke-RestMethod -Uri $Webhook -Method Post -Body $ConvertedBody -ErrorAction Stop
    }
    catch
    {
        # We can't control what a user enters in the SubBlocks parameter, so try to warn them if they've got something wrong
        if ($SubBlocks)
        {
            $AdditionalError = " You are using SubBlocks, it's possible that your SubBlocks are malformed, try removing them and running the command again."
        }
        Write-Error "Failed to send Slack notification$AdditionalError.`n$($_.Exception.Message)"
    }
}
