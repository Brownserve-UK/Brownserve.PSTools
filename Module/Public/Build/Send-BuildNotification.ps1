function Send-BuildNotification
{
    [CmdletBinding()]
    param
    (
        # The name of the build that is being reported on.
        [Parameter(
            Mandatory = $false,
            Position = 0
        )]
        [string]
        $BuildName,

        # The status of the build.
        [Parameter(
            Mandatory = $true,
            Position = 1
        )]
        [ValidateSet('Success', 'Fail', 'Information', 'Warning', 'Failure', 'Cancelled')]
        [Alias('Status')]
        [string]
        $BuildStatus,

        # The webhook URL to send the notification to.
        [Parameter(
            Mandatory = $false,
            Position = 2
        )]
        [string]
        $Webhook = $env:BUILD_NOTIFICATION_WEBHOOK,

        # The message to send (optional).
        [Parameter(
            Mandatory = $false, 
            Position = 3
        )]
        [string]
        $Message,

        # The push message to send (optional).
        [Parameter(
            Mandatory = $false,
            Position = 4
        )]
        [string]
        [alias('Push','Title')]
        $PushMessage
    )
    
    begin
    {
        if (!$Webhook)
        {
            throw "No webhook specified."
        }
        if (!$BuildName)
        {
            try
            {
                $BuildName = Split-Path $MyInvocation.PSCommandPath -Leaf
            }
            catch
            {
                throw "Failed to get the name of the build programmatically."
            }
        }
    }
    
    process
    {
        $Fields = @(
            @{
                title = 'Repo:'
                value = $global:RepoName
                short = $true
            },
            @{
                title = 'Build:'
                value = "$BuildName"
                short = $true
            }
        )
        if ($env:BUILD_BRANCH)
        {
            $Fields += @{
                title = 'Branch:'
                value = $env:BUILD_BRANCH
                short = $false
            }
        }
        switch -Regex ($BuildStatus)
        {
            '[Ss]uccess'
            {
                $Colour = '#007C00'
                if (!$PushMessage)
                {
                    $PushMessage = "$BuildName has completed successfully."
                }
                if (!$Message)
                {
                    $Message = "$BuildName has completed successfully."
                }
            }
            '[Ff]ail'
            {
                $Colour = '#FF0000'
                if (!$PushMessage)
                {
                    $PushMessage = "$BuildName has failed."
                }
                if (!$Message)
                {
                    $Message = "$BuildName has failed."
                }
            }
            '[Ii]nformation'
            {
                $Colour = '#00c4ff'
                if (!$PushMessage)
                {
                    $PushMessage = "$BuildName has completed with information."
                }
                if (!$Message)
                {
                    $Message = "$BuildName has completed with information."
                }
            }
            '[Ww]arning'
            {
                $Colour = '#ffc000'
                if (!$PushMessage)
                {
                    $PushMessage = "$BuildName has completed with a warning."
                }
                if (!$Message)
                {
                    $Message = "$BuildName has completed with a warning."
                }
            }
            '[Cc]ancelled'
            {
                $Colour = '#808080'
                if (!$PushMessage)
                {
                    $PushMessage = "$BuildName has been cancelled."
                }
                if (!$Message)
                {
                    $Message = "$BuildName has been cancelled."
                }
            }
        }
        # For now we only support sending to Slack.
        try
        {
            Send-SlackNotification `
                -Message $Message `
                -Webhook $Webhook `
                -Colour $Colour `
                -Title $PushMessage `
                -Fields $Fields
        }
        catch
        {
            Write-Error "Failed to send notification.`n$($_.Exception.Message)"
        }
    }
    end
    {
        
    }
}   