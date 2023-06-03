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

        # If set forces a reload of the module your building docs for if it's already loaded
        [Parameter(Mandatory = $false)]
        [switch]
        $ReloadModule,

        # If set parameters marked as 'DontShow' will be included
        [Parameter(Mandatory = $false)]
        [switch]
        $IncludeDontShow,

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
            # N.B. we always import using the -Global flag because otherwise when this module gets unloaded as part of the -ReloadModule flag
            # it takes any imported modules with it 😬
            if (!$PreloadedPlatyPS)
            {
                if ($Global:BrownserveRepoPlatyPSPath)
                {
                    Write-Verbose 'Loading local version of platyPS'
                    Import-Module $Global:BrownserveRepoPlatyPSPath -Force -Global -ErrorAction 'Stop' -Verbose:$false
                }
                # Otherwise attempt to load any version installed on the system
                else
                {
                    Write-Verbose 'Loading system version of platyPS'
                    Import-Module 'PlatyPS' -Force -Global -ErrorAction 'Stop' -Verbose:$false
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
                Import-Module -Name $ModulePath -Force -Global -ErrorAction 'Stop' -Verbose:$false
            }
            # Try to keep the version of help in lockstep with the version of the module
            $ModuleDetails = Get-Module -Name $ModuleName 
            $HelpVersion = $ModuleDetails | Select-Object -ExpandProperty Version
            $ModuleDescription = $ModuleDetails | Select-Object -ExpandProperty Description

            # TODO: The below can be revisited when we've got updatable help figured out
            # # Lets see if the module is part of a git repo, and if it is then try to work out the URL for the docs would be
            # $ModuleRepoURL = Get-GitRemoteOriginURL -ErrorAction 'SilentlyContinue' | ConvertTo-HTTPSRepoURL -ErrorAction 'SilentlyContinue'
            # if ($ModuleRepoURL)
            # {
            #     $HelpDocsLink = $ModuleRepoURL + "/tree/v$HelpVersion/$DocumentationPath/$ModuleName"
            # }

            # Create a directory with the name of module to be used to store the docs
            $ModuleDocumentationDirectory = Join-Path $DocumentationPath $ModuleName
            if (!(Test-Path $ModuleDocumentationDirectory))
            {
                $ErrorStep = 'Failed to create module documentation directory'
                New-Item $ModuleDocumentationDirectory -ItemType Directory -ErrorAction 'Stop' | Out-Null
            }
            $PublicCmdletDocPath = $ModuleDocumentationDirectory
            $ModulePagePath = Join-Path $DocumentationPath "$($ModuleName).md"

            if (!(Test-Path $PublicCmdletDocPath))
            {
                $ErrorStep = 'Failed to create public cmdlet directory.'
                New-Item $PublicCmdletDocPath -ItemType Directory -ErrorAction 'Stop' | Out-Null
            }

            $PlatyParams = @{
                AlphabeticParamsOrder = $true
                ModulePagePath        = $ModulePagePath
            }
    
            if (!$IncludeDontShow)
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
                if ($HelpVersion)
                {
                    $NewDocsParams.Add('HelpVersion', $HelpVersion)
                }
                if ($HelpDocsLink)
                {
                    $NewDocsParams.Add('FWLink', $HelpDocsLink)
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
            $ModulePageContent = Get-Content $ModulePagePath -ErrorAction 'Stop' -Raw
            if (!$ModulePageContent)
            {
                throw 'Module page content appears to be blank'
            }
            $ModulePageAdjustment = Split-Path $PublicCmdletDocPath -Leaf
            $SanitizedModulePageContent = $ModulePageContent -replace '\(([\w|\d]*-[\w|\d]*.md)\)', "(./$ModulePageAdjustment/`$1)"

            # If we've passed in a GUID for the module then update the module page with that.
            if ($ModuleGUID)
            {
                $SanitizedModulePageContent = $SanitizedModulePageContent -replace '00000000-0000-0000-0000-000000000000', $ModuleGUID
            }
            if ($HelpVersion)
            {
                Write-Verbose "New help version: $HelpVersion"
                if ($SanitizedModulePageContent -imatch 'Help Version: (?<version>.*\n)')
                {
                    [version]$CurrentHelpVersion = $Matches['version']
                    if ([version]$HelpVersion -ne $CurrentHelpVersion)
                    {
                        $HelpVersionString = $HelpVersion.ToString()
                        $CurrentHelpVersionString = $CurrentHelpVersion.ToString()
                        $SanitizedModulePageContent = $SanitizedModulePageContent.Replace("Help Version: $CurrentHelpVersionString", "Help Version: $HelpVersionString")
                    }
                }
                else
                {
                    Write-Warning "Couldn't find help version number in the module page content."
                }
            }

            if ($ModuleDescription)
            {
                if ($SanitizedModulePageContent -imatch '## Description[\s\n]*{{ Fill in the Description }}')
                {
                    # .Replace method doesn't work 🤷‍♀️ so use the -replace param instead.
                    $SanitizedModulePageContent = $SanitizedModulePageContent -Replace '## Description[\s\n]*{{ Fill in the Description }}', "## Description`n$ModuleDescription"
                }
            }
            $ErrorStep = "Failed to update module page with sanitized content at '$ModulePagePath'"
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