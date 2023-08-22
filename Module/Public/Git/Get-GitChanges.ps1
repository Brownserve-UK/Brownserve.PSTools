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
        $Path = $PWD,

        # If set will use the porcelain version of the status command which ensures stability of the output
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [switch]
        $UsePorcelain
    )
    
    begin
    {
        $Changes = @()
    }
    
    process
    {
        try
        {
            $Arguments = @('-c','color.status=false','status')
            if ($UsePorcelain.IsPresent)
            {
                $Arguments += '--porcelain'
            }
            else
            {
                $Arguments += '--short'
            }
            $Status = Invoke-NativeCommand `
                -FilePath 'git' `
                -ArgumentList $Arguments `
                -WorkingDirectory $Path `
                -SuppressOutput `
                -PassThru `
                -ErrorAction 'Stop'
            <#
                As it stands the output of the git status --short command is the same as the porcelain version with the added bonus that the paths are
                relative to the working directory. The porcelain version of the command is more stable and is less likely to change in the future as it
                is designed to be used by scripts. The downside is that the paths are relative to the repository root and not the working directory.
                We make the conscious decision to use the --short version of the command by default and accept that it may change in the future necessitating
                a change to this function. We provide the -UsePorcelain switch to allow the user to use the more stable version of the command if they wish.
            #>
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
                    }
                    else
                    {
                        $Source = $Path
                        $Destination = $null
                    }
                    # The status is a combination of two characters, the first is the staged status and the second is the unstaged status
                    # so we need to split them up
                    [GitDiff]$StagedStatus = $Status[0] | Out-String -NoNewline
                    [GitDiff]$UnstagedStatus = $Status[1] | Out-String -NoNewline
                    $Change = [GitStatus]@{
                        'Staged'      = $StagedStatus
                        'Unstaged'    = $UnstagedStatus
                        'Source'      = $Source
                        'Destination' = $Destination
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