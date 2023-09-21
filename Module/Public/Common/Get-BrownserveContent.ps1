<#
.SYNOPSIS
    Wrapper for Get-Content that returns the content in a format that is easier to work with.
.DESCRIPTION
    TODO: Elaborate on the description.
    This cmdlet ensures that any content is returned in a format that is easy to work with in pipelines.
#>
function Get-BrownserveContent
{
    [CmdletBinding()]
    param
    (
        # The path to the file to get content from
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true,
            Position = 0
        )]
        [Alias('PSPath')]
        [string[]]
        $Path
    )

    begin
    {
        $Return = @()
    }

    process
    {
        try
        {
            $Path | ForEach-Object {
                $Content = Get-Content -Path $_ -ErrorAction 'Stop' -ReadCount 0
                $Path = Get-Item -Path $_ -ErrorAction 'Stop'
                $Return += [BrownserveContent]@{
                    Content = $Content
                    Path = $Path
                }
            }
        }
        catch
        {
            throw "Failed to get content from path '$_'.`n$($_.Exception.Message)"
        }
    }

    end
    {
        if ($Return.Count -gt 0)
        {
            return $Return
        }
        else
        {
            return $null
        }
    }
}
