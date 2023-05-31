<#
.SYNOPSIS
    This will build PowerShell module documentation using PlatyPS
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.NOTES
    Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>
function Build-ModuleDocumentation
{
    [CmdletBinding()]
    param
    (
        # The name of the module to have the help created for
        [Parameter(Mandatory = $true)]
        [string]
        $ModuleName,

        # The path to the module
        [Parameter(Mandatory = $true)]
        [string]
        $ModulePath,

        # The directory that the help should be stored in
        [Parameter(Mandatory = $true)]
        [string]
        $DocumentationPath,
    
        # Whether or not to include private cmdlet documentation
        [Parameter(Mandatory = $false)]
        [bool]
        $IncludePrivate = $true,

        # Whether or not to force a reload of the module if it's already loaded
        [Parameter(Mandatory = $false)]
        [bool]
        $ReloadModule = $true,

        # Whether or not to ignore parameters marked as 'DontShow'
        [Parameter(Mandatory = $false)]
        [bool]
        $IgnoreDontShow = $true,

        # The GUID of the module (if desired)
        [Parameter(Mandatory = $false)]
        [guid]
        $ModuleGUID
    )
    
    begin
    {
        # Ensure the documentation directory is indeed a dir
        Assert-Directory $DocumentationPath -ErrorAction 'Stop'

        # First we check if the module is already loaded
        $PreloadedPlatyPS = Get-Module -Name 'PlatyPS'
        # If it is then we don't need to do anything, the user has already provided us with platyPS

        try
        {
            # First see if the special Brownserve variable is set, if so attempt to download the version from the repo.
            if (!$PreloadedPlatyPS)
            {
                if ($Global:BrownserveRepoPlatyPSPath)
                {
                    Import-Module $Global:BrownserveRepoPlatyPSPath -Force -ErrorAction 'Stop'
                }
                # Otherwise attempt to load any version installed on the system
                else
                {
                    Import-Module 'PlatyPS' -Force -ErrorAction 'Stop'
                }
            }
        }
        catch
        {
            $ErrorMessage = 'Failed to load platyPS module.'
            if (!$Global:BrownserveRepoPlatyPSPath)
            {
                $ErrorMessage += "`nThe '`$Global:BrownserveRepoPlatyPSPath' variable has not been set and PowerShell failed to load any versions installed locally."
            }
            throw "$ErrorMessage.`n$($_.Exception.Message)"
        }

        $Return = @()
    }
    
    process
    {
        # We'll encapsulate everything in one big try/catch block so we can unload the module if we have to.
        # Once we can run platyPS and powershell-yaml side-by-side then we can refactor this hot mess.
        try
        {
            $ModuleDirectory = Get-Item (Split-Path $ModulePath) | Convert-Path

            # Check if the module is already loaded
            $ModuleLoaded = Get-Module -Name $ModuleName -ErrorAction 'SilentlyContinue'
            # Sometimes we may want to unload the module and reload it, especially if we've been working on changes as this ensures anything new will be picked up.
            if ($ModuleLoaded -and $ReloadModule)
            {
                $ErrorStep = "Unable to unload module '$ModuleName'"
                Remove-Module $ModuleName -Force -ErrorAction 'Stop'
            }
            if (!$ModuleLoaded -or $ReloadModule)
            {
                $ErrorStep = "Failed to import module '$ModuleName' from $ModulePath."
                Import-Module -Name $ModulePath -Force -Global -ErrorAction 'Stop' 
            }
            # Create a directory with the name of module to be used to store the docs
            $ModuleDocumentationDirectory = Join-Path $DocumentationPath $ModuleName
            if (!(Test-Path $ModuleDocumentationDirectory))
            {
                $ErrorStep = 'Failed to create module documentation directory'
                New-Item $ModuleDocumentationDirectory -ItemType Directory -ErrorAction 'Stop' | Out-Null
            }

            <#
                Sometimes we may want to document the private functions from a given module in markdown instead of just commenting in the cmdlets themselves.
                This is usually the case when they are complicated or unusual.
                To do this we create a temporary module that contains all the private cmdlets to pass to platyPS.
                We also change separate the documentation by public/private.
            #>
            if ($IncludePrivate)
            {
                $PublicCmdletDocPath = Join-Path $ModuleDocumentationDirectory 'Public'
                $PrivateCmdletDocPath = Join-Path $ModuleDocumentationDirectory 'Private'
                $ModulePagePath = Join-Path $ModuleDocumentationDirectory "$($ModuleName).md"
                $PrivateModuleName = "$($ModuleName)Private"
                $ErrorStep = 'Failed to determine module parent.'
                $ModuleParent = Get-Item $ModulePath | Select-Object -ExpandProperty PSParentPath | Convert-Path
                $PrivateModuleContent = @"
[CmdletBinding()]
param()
`$ErrorActionPreference = 'Stop'

Resolve-Path '$(Join-Path $ModuleParent 'Private')' |
    Resolve-Path |
    Get-ChildItem -Filter *.ps1 -Recurse |
        ForEach-Object {
        . `$_.FullName
        Export-ModuleMember -Function `$_.BaseName
        }
"@                
                $ErrorStep = 'Failed to create temporary module for private cmdlets.'
                $TempPrivateModule = New-BrownserveTemporaryFile `
                    -FileName $PrivateModuleName `
                    -FileExtension '.psm1' `
                    -Content $PrivateModuleContent `
                    -ErrorAction 'Stop'

                <# 
                    the -Global param is needed here due to some quirk in PlatyPS/PowerShell, if it's not used it doesn't seem to pick up that the module has been loaded :/
                #>
                $ErrorStep = 'Failed to import temporary module for private cmdlets.'
                Import-Module $TempPrivateModule -Force -ErrorAction 'Stop' -Global

                if (!(Test-Path $PrivateCmdletDocPath))
                {
                    $NewPrivateDocsParams = @{
                        Module                = $PrivateModuleName
                        OutputFolder          = $PrivateCmdletDocPath
                        AlphabeticParamsOrder = $true
                    }
                    if ($IgnoreDontShow)
                    {
                        $NewPrivateDocsParams.Add('ExcludeDontShow', $true)
                    }

                    $ErrorStep = 'Failed to create private cmdlet directory.'
                    New-Item $PrivateCmdletDocPath -ItemType Directory -ErrorAction 'Stop' | Out-Null
                    $ErrorStep = 'Failed to create private cmdlet documentation.'
                    New-MarkdownHelp @NewPrivateDocsParams -ErrorAction 'Stop' | Out-Null
                }
                else
                {
                    $UpdatePrivateDocsParams = @{
                        Path                  = $PrivateCmdletDocPath
                        AlphabeticParamsOrder = $true
                        UpdateInputOutput     = $true
                        Force                 = $true # This is a poorly named parameter it actually just deletes cmdlets that have been removed.
                    }
                    if ($IgnoreDontShow)
                    {
                        $UpdatePrivateDocsParams.Add('ExcludeDontShow', $true)
                    }
                    $ErrorStep = "Failed to update private cmdlet documentation for $ModuleName."
                    Update-MarkdownHelpModule @UpdatePrivateDocsParams -ErrorAction 'Stop' | Out-Null
                }
            }
            else
            {
                $PublicCmdletDocPath = $ModuleDocumentationDirectory
                $ModulePagePath = Join-Path $DocumentationPath "$($ModuleName).md"
            }

            if (!(Test-Path $PublicCmdletDocPath))
            {
                $ErrorStep = 'Failed to create public cmdlet directory.'
                New-Item $PublicCmdletDocPath -ItemType Directory -ErrorAction 'Stop' | Out-Null
            }

            $PlatyParams = @{
                AlphabeticParamsOrder = $true
                ModulePagePath        = $ModulePagePath
            }
    
            if ($IgnoreDontShow)
            {
                $PlatyParams.Add('ExcludeDontShow', $true)
            }

            $ExistingDocs = Get-Item $ModulePagePath -ErrorAction 'SilentlyContinue'

            if (!$ExistingDocs)
            {
                $NewDocsParams = $PlatyParams
                $NewDocsParams.Add('OutputFolder', $PublicCmdletDocPath)
                $NewDocsParams.Add('Module', $ModuleName)
                $NewDocsParams.Add('WithModulePage', $true)
                $NewDocsParams.Add('HelpVersion', '0.1.0')
                if ($ModuleGUID)
                {
                    $NewDocsParams.Add('ModuleGUID', $ModuleGUID)
                }
                $ErrorStep = "Failed to build new module documentation for $ModuleName."
                # Mute warnings as cmdlets that are not yet documented will cause complaints 🙄
                New-MarkdownHelp @NewDocsParams -ErrorAction 'Stop' -WarningAction 'SilentlyContinue' | Out-Null
            }
            else
            {
                $UpdateDocsParams = $PlatyParams
                $UpdateDocsParams.Add('Path', $PublicCmdletDocPath)
                $UpdateDocsParams.Add('RefreshModulePage', $true)
                $UpdateDocsParams.Add('UpdateInputOutput', $true)
                $UpdateDocsParams.Add('Force', $true) # This is a poorly named parameter it actually just deletes cmdlets that have been removed.
                # For some reason we get a lot of warnings when using the update cmdlet that make no sense, so just mute them for now.
                $ErrorStep = 'Failed to update module documentation'
                Update-MarkdownHelpModule @UpdateDocsParams -ErrorAction 'Stop' -WarningAction 'SilentlyContinue' | Out-Null
            }

            <#
                Currently PlatyPS expects the Module page to be in the same directory as the help files and as such hard-codes the links :(
                To get around this we'll import the page content and then adjust the links using regex to point them at the right place.
                We may be able to remove the below once this issue is resolved: https://github.com/PowerShell/platyPS/issues/451
            #>
            $ErrorStep = "Failed to retrieve module page content from '$ModulePagePath'."
            $ModulePageContent = Get-Content $ModulePagePath -ErrorAction 'Stop'
            
            
            $ModulePageAdjustment = Split-Path $PublicCmdletDocPath -Leaf
            $SanitizedModulePageContent = $ModulePageContent -replace '\(([\w|\d]*-[\w|\d]*.md)\)', "(./$ModulePageAdjustment/`$1)"
            $ErrorStep = "Failed to sanitize documentation links in $ModulePagePath."
            Set-Content $ModulePagePath -Value $SanitizedModulePageContent -ErrorAction 'Stop'

            # Create some sensible return so that we can pipe it into a cmdlet to update the MALM
            $Return += [pscustomobject]@{
                ModuleDirectory   = $ModuleDirectory
                HelpLanguage      = 'en-US' # Hardcoded as we only support the one atm
                DocumentationPath = ($PublicCmdletDocPath | Convert-Path) # Only the public cmdlets need to be documented
            }
        }
        catch
        {
            $ErrorMessage = 'Failed to build module documentation.'
            if ($ErrorStep)
            {
                $ErrorMessage += "`n$ErrorStep"
            }
            $ErrorMessage += "`n$($_.Exception.Message)"
            throw $ErrorMessage
        }
        finally
        {
            <#
                If we've created a temporary private module then we should remove it
            #>
            if ($TempPrivateModule)
            {
                Remove-Module $PrivateModuleName -Force -ErrorAction 'SilentlyContinue'
                Remove-Item $TempPrivateModule -Force -ErrorAction 'SilentlyContinue'
            }
            <# 
                If we've loaded platyPS as part of this cmdlet then chances are we're going to want to un-load it
                This is due to https://github.com/PowerShell/platyPS/issues/592 and the fact we make use of powershell-yaml in places too
            #>
            if (!$PreloadedPlatyPS)
            {
                Remove-Module 'platyPS' -Force -ErrorAction 'SilentlyContinue'
                if ((Get-Module 'platyPS'))
                {
                    Write-Error 'Failed to unload platyPS module.'
                }
            }
        }  
    }
    
    end
    {
        if ($Return -ne @())
        {
            return $Return
        }
        else
        {
            return $null
        }
    }
}