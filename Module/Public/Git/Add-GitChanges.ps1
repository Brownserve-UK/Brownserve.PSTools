<#
.SYNOPSIS
    This cmdlet is a wrapper for the git command 'git add <path>'.
.DESCRIPTION
    This command selects the git changes from the working tree to prepare the content staged for the next commit.
#>
function Add-GitChanges
{
    [CmdletBinding()]
    param
    (
        # The path to the file to be added to the next commit
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [string[]]
        $Path,

        # The path to the git repository
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 2
        )]
        [string]
        $RepositoryPath = $PWD
    )
    begin
    {
    }
    process
    {
        $Path | ForEach-Object {
            $File = $_
            try
            {
                Invoke-NativeCommand `
                    -FilePath 'git' `
                    -ArgumentList @('add', $_) `
                    -WorkingDirectory $RepositoryPath `
                    -SuppressOutput `
                    -ErrorAction Stop
            }
            catch
            {
                throw "Failed to stage file '$File'.`n$($_.Exception.Message)"
            }
        }
    }
    end
    {
    }
}
