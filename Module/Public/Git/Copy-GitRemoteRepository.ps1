function Copy-GitRemoteRepository
{
    [CmdletBinding()]
    param
    (
        # The URI of the remote repository to clone
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $URI,

        # The path to store the repository locally
        [Parameter(Mandatory = $false, Position = 1)]
        [string]
        $Path = $PWD
    )
    
    begin
    {
        # Ensure both git and the path we want to clone to exist before continuing
        Assert-Directory $Path
        Assert-Command 'git'
    }
    
    process
    {
        try
        {
            Invoke-NativeCommand `
                -FilePath 'git' `
                -ArgumentList @('clone', $URI) `
                -WorkingDirectory $Path `
                -SuppressOutput `
                -PassThru `
                -ErrorAction 'Stop' | Select-Object -ExpandProperty 'OutputContent'
        }
        catch
        {
            throw "Failed to clone repository '$URI'.`n$($_.Exception.Message)"
        }
    }
    
    end
    {
        
    }
}