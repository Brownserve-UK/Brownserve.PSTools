function Set-TerraformLogLevel
{
    [CmdletBinding()]
    param
    (
         # The log level to set
         [Parameter(
            Mandatory = $false,
            Position = 0
        )]
        [ValidateSet('DEBUG', 'TRACE', 'INFO', 'WARN', 'ERROR', 'none')]
        [string]
        $LogLevel = 'none'
    )
    Write-Warning "This cmdlet is deprecated and will be removed in a future release."
    # Set TF_LOG to a blank string first - it's the only way to be sure we get the correct log-level
    $env:TF_LOG = ''
    if ($LogLevel -ne 'none')
    {
        Write-Verbose "Setting TF_LOG to $LogLevel"
        $env:TF_LOG = $LogLevel
    }
}