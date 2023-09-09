<#
.SYNOPSIS
    This cmdlet is a wrapper for <git commit>.
.DESCRIPTION
    This cmdlet will commit all staged changes to the local repository.
#>
function Submit-GitChanges
{
    [CmdletBinding()]
    param
    (
        # The message to use for the commit.
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,

        # The path to the local repository.
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Path')]
        [string]
        $RepositoryPath = $PWD
    )
    begin
    {
        Assert-Directory $RepositoryPath -ErrorAction 'Stop'
    }
    process
    {
        try
        {
            $Return = Invoke-NativeCommand `
                -FilePath 'git' `
                -WorkingDirectory $RepositoryPath `
                -ArgumentList 'commit', '-m', $Message `
                -ErrorAction 'Stop' `
                -PassThru `
                -SuppressOutput | Select-Object -ExpandProperty OutputContent
        }
        catch
        {
            throw "Failed to commit changes to the local repository.`n$($_.Exception.Message)"
        }
    }
    end
    {
        if ($Return)
        {
            return $Return
        }
        else
        {
            return $null
        }
    }
}
