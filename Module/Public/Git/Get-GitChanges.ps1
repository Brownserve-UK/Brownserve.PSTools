function Get-GitChanges
{
    [CmdletBinding()]
    param
    (
        # The path to the git repository to query
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [string]
        $Path = $PWD
    )
    
    begin
    {
        $Changes = @()
    }
    
    process
    {
        try
        {
            $Status = Invoke-NativeCommand `
                -FilePath 'git' `
                -ArgumentList @('status', '--porcelain') `
                -WorkingDirectory $Path `
                -SuppressOutput `
                -PassThru `
                -ErrorAction 'Stop'
            $Status = $Status | Select-Object -ExpandProperty 'OutputContent'
            # Split the status into lines and process each line to work out what the status is
            $Status | ForEach-Object {
                if ($_ -match '^(?<Status>[?!ACDMTRU ]{1,2})\s+(?<Path>.*)$')
                {
                    $Status = $Matches['Status']
                    $Path = $Matches['Path']
                    # If the path is a rename/move then we need to split it into the source and destination
                    if ($Path -match '^{(?<Source>.*) -> (?<Destination>.*)}$')
                    {
                        $Source = $Matches['Source']
                        $Destination = $Matches['Destination']
                        $File = [pscustomobject]@{
                            'Source'      = $Source
                            'Destination' = $Destination
                        }
                    }
                    else
                    {
                        $File = [pscustomobject]@{
                            'Source'      = $Path
                            'Destination' = $null
                        }
                    }
                    # The status is a combination of two characters, the first is the staged status and the second is the unstaged status
                    # so we need to split them up
                    [GitStatus]$StagedStatus = $Status[0] | Out-String -NoNewline
                    [GitStatus]$UnstagedStatus = $Status[1] | Out-String -NoNewline
                    $Change = [pscustomobject]@{
                        'Changes' = [pscustomobject]@{
                            'Staged'   = $StagedStatus
                            'Unstaged' = $UnstagedStatus
                        }
                        'File'   = $File
                    }
                    $Changes += $Change
                }
                else
                {
                    throw "Unable to parse git status line: $_"
                }
            }
        }
        catch
        {
            throw "Failed to resolve git status. `n$($_.Exception.Message)"
        }
    }
    
    end
    {
        if ($Changes.Count -gt 0)
        {
            return $Changes
        }
        else
        {
            return $null
        }
    }
}