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
        [ValidateSet('Success', 'Fail', 'Information', 'Warning')]
        [string]
        $BuildStatus,

        # The webhook URL to send the notification to.
        [Parameter(
            Mandatory = $true,
            Position = 2
        )]
        [string]
        $Webhook,

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
        [alias('Push')]
        $PushMessage
    )
    
    begin
    {
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
        switch ($BuildStatus)
        {
            'Success'
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
            'Fail'
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
            'Information'
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
            'Warning'
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