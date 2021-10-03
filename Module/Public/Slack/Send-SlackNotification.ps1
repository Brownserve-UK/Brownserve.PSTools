function Invoke-SlackNotification
{
    [CmdletBinding()]
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
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $Colour, 
    
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $Push
    )
    # Let's initialize an empty hash table
    $SlackBody = 
    @{
        Attachments = 
        @(
            @{
            }
        )
    }

    # Add any given optional parameters to the hash table.
    if ($Colour)
    {
        ($SlackBody.Attachments)[0] += 
        @{
            'color' = $Colour
        }
    }

    if ($Push)
    {
        ($SlackBody.Attachments)[0] += 
        @{
            'fallback' = $Push
        }
    }

    ($SlackBody.Attachments)[0] += 
    @{
        'text' = $Message
    }
    try
    {
        invoke-RestMethod -Uri $Webhook -Method Post -Body (ConvertTo-Json $SlackBody) -ErrorAction Stop
    }
    catch
    {
        Write-Error "Failed to send Slack notification.$($_.Exception.Message)"
    }
}
