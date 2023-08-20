function Invoke-ConvertFromYaml
{
    [CmdletBinding()]
    param
    (
        # The thing to be converted
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $InputObject,

        # Any options to be passed to ConvertFrom-YAML
        [Parameter(
            Mandatory = $false,
            Position = 1
        )]
        [hashtable]
        $Parameters
    )
    
    begin
    {
        
    }
    
    process
    {
        <#
            There's an incompatibility between PlatyPS and PowerShell-YAML due to them both using the same assembly but requiring different versions.
            See https://github.com/PowerShell/platyPS/issues/592 for more information.
            This should be fixed in the future but PlatyPS are being very slow to ship the fix.
            As it's very hard to completely get around this in the same session we'll create a new pwsh process to do the conversion.
            We use a scriptblock to do this so that we can pass in the variable parameters and the input object.
        #>
        $ScriptBlock = {
            param($Arguments)
            $Return = $null
            # First load the module
            try
            {
                if ($Arguments.PowerShellYAMLPath)
                {
                    Import-Module $Arguments.PowerShellYAMLPath `
                        -Force `
                        -ErrorAction 'Stop' `
                        -Verbose:$false
                }
                else
                {
                    Import-Module 'powershell-yaml' `
                        -Force `
                        -ErrorAction 'Stop' `
                        -Verbose:$false
                }
            }
            catch
            {
                $ErrorMessage = 'Failed to load powershell-yaml module.'
                if (!$Arguments.PowerShellYAMLPath)
                {
                    $ErrorMessage += "`nThe '`$Global:BrownserveRepoPowerShellYAMLPath' variable has not been set and PowerShell failed to load any versions installed locally."
                }
                throw "$ErrorMessage.`n$($_.Exception.Message)"
            }

            try
            {
                # Seems like splatting "$null" causes weirdness, so only splat if we have params
                if ($null -ne $Arguments.YamlParameters)
                {
                    $YamlParameters = $Arguments.YamlParameters
                    $Return = ConvertFrom-Yaml -Yaml $Arguments.InputObject @YamlParameters -ErrorAction 'Stop'
                }
                else
                {
                    $Return = ConvertFrom-Yaml -Yaml $Arguments.InputObject -ErrorAction 'Stop'
                }
            }
            catch
            {
                throw "`n$($_.Exception.Message)"
            }
            return $Return
        }

        try
        {
            $Arguments = @{
                InputObject = $InputObject
            }
            if ($Global:BrownserveRepoPowerShellYAMLPath)
            {
                $Arguments.Add('PowerShellYAMLPath',$Global:BrownserveRepoPowerShellYAMLPath)
            }
            if ($Parameters)
            {
                $Arguments.Add('YamlParameters',$Parameters)
            }
            $Result = & pwsh -NoLogo -NonInteractive -Command $ScriptBlock -Args $Arguments
            if ($LASTEXITCODE -ne 0)
            {
                throw "Pwsh failed with exitcode $LASTEXITCODE"
            }
        }
        catch
        {
            throw "Failed to convert YAML into a PowerShell object. `n$($_.Exception.Message)"
        }
    }
    
    end
    {
        if ($Result)
        {
            return $Result
        }
        else
        {
            return $null
        }
    }
}