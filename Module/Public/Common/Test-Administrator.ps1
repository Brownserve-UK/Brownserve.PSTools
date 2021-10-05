function Test-Administrator
{
    [CmdletBinding()]
    param
    ()
    begin {}
    process
    {
        switch -regex ($global:OS)
        {
            'Windows'
            {
                $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                $Return = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
                Return $Return
            }
            'Linux|macOS'
            {
                $WhoAmI = Start-SilentProcess `
                    -FilePath 'whoami' `
                    -PassThru | Select-Object -ExpandProperty 'OutputContent'
                if ($WhoAmI -eq 'root')
                {
                    Return $true
                }
                else
                {
                    Return $false
                }
            }
            Default
            {
                throw "Cannot test administrator on $global:OS"
            }
        }
    }
    end
    {}
}