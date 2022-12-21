function Test-OperatingSystem
{
    [CmdletBinding()]
    param
    (
        # The operating system(s) that should be supported
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [OperatingSystemKernel[]]
        $SupportedOS = @('Windows', 'Linux', 'macOS')
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
        }
        if ($IsLinux)
        {
            if ('Linux' -notin $SupportedOS)
            {
                throw 'This cmdlet is not supported on Linux'
            }
        }
        if ($IsMacOS)
        {
            if ('macOS' -notin $SupportedOS)
            {
                throw 'This cmdlet is not supported on macOS'
            }
        }
    }
    
    end
    {
        
    }
}