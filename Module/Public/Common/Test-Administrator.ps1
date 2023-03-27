function Test-Administrator
{
    [CmdletBinding()]
    param
    ()
    begin {}
    process
    {
        if ($IsWindows)
        {
            $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
            $Return = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
            Return $Return
        }
        else
        {
            $UID = & id -u
            if ($UID -eq 0)
            {
                Return $true
            }
            else
            {
                Return $false
            }
        }
    }
    end
    {}
}