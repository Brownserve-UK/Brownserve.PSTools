function Test-OperatingSystem
{
    [CmdletBinding()]
    param
    (
        # The operating system(s) that should be supported
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [OperatingSystemKernel[]]
        $SupportedOS
    )
    
    begin
    {
        
    }
    
    process
    {
        if ($IsWindows)
        {
            if ('Windows' -notin $SupportedOS)
            {
                throw 'This cmdlet is not supported on Windows'
            }
            $OS = 'Windows'
        }
        if ($IsLinux)
        {
            if ('Linux' -notin $SupportedOS)
            {
                throw 'This cmdlet is not supported on Linux'
            }
            $OS = 'Linux'
        }
        if ($IsMacOS)
        {
            if ('macOS' -notin $SupportedOS)
            {
                throw 'This cmdlet is not supported on macOS'
            }
            $OS = 'macOS'
        }
        Write-Verbose "This cmdlet is supported on $OS"
    }
    
    end
    {
        
    }
}