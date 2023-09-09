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
        $ModuleGUID,

        # The help version number to use
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true
        )]
        [System.Management.Automation.SemanticVersion]
        $HelpVersion
    )
    begin
    {
        # Ensure the documentation directory is indeed a dir
        Assert-Directory $DocumentationPath -ErrorAction 'Stop'

        # First we check if the module is already loaded
        $PreloadedPlatyPS = Import-PlatyPSModule -ErrorAction 'Stop'

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
            $ModuleDetails = Get-Module -Name $ModuleName
            # We no longer generate the help version here, we rely on it being passed in.
            # If we need to bring this back in the future we can make a param like -GenerateVersion or something
            # if (!$HelpVersion)
            # {
            #     $HelpVersion = ($ModuleDetails | Select-Object -ExpandProperty Version).ToString()
            #     if ($ModuleDetails.PrivateData.PSData.Prerelease)
            #     {
            #         $HelpVersion = "$($HelpVersion.Value)-$($ModuleDetails.PrivateData.PSData.Prerelease)"
            #     }
            # }
            if (!$ModuleGUID)
            {
                $ModuleGUID = $ModuleDetails.Guid.Guid
            }
            else
            {
                if ($ModuleGUID -ne $ModuleDetails.Guid.Guid)
                {
                    throw "Module GUID '$ModuleGUID' doesn't match the GUID of the module '$($ModuleDetails.Guid.Guid)'."
                }
            }
            $ModuleDescription = $ModuleDetails | Select-Object -ExpandProperty Description

            # TODO: The below can be revisited when we've got updatable help figured out
            # # Lets see if the module is part of a git repo, and if it is then try to work out the URL for the docs would be
            # $ModuleRepoURL = Get-GitRemoteOriginURL $DocumentationPath -ErrorAction 'SilentlyContinue' | ConvertTo-HTTPSRepoURL -ErrorAction 'SilentlyContinue'
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
                Deal with the module page which has some quirks that we need to work around.
                These were originally part of this cmdlet but have been moved to their own cmdlets to make it easier to
                update the module page without having to rebuild the help for the module.
                Especially useful during CI/CD pipelines.
            #>

            # First ensure the links are correct
            Update-PlatyPSModulePageLinks `
                -CmdletDocumentationPath $PublicCmdletDocPath `
                -ModulePagePath $ModulePagePath `
                -ErrorAction 'Stop'

            # If we've passed in a GUID for the module then update the module page with that.
            if ($ModuleGUID)
            {
                Update-PlatyPSModulePageGUID `
                    -ModuleGUID $ModuleGUID `
                    -ModulePagePath $ModulePagePath `
                    -ErrorAction 'Stop'
            }
            <#
                We only update the help version number if it has been passed in
                this is mostly because it's handled by our build pipelines so we'll rarely (if ever) need to
                update it manually.
            #>
            if ($HelpVersion)
            {
                Update-PlatyPSModulePageHelpVersion `
                    -HelpVersion $HelpVersion `
                    -ModulePagePath $ModulePagePath `
                    -ErrorAction 'Stop'
            }

            # If we've passed in a module description then update the module page with that.
            if ($ModuleDescription)
            {
                Update-PlatyPSModulePageDescription `
                    -ModuleDescription $ModuleDescription `
                    -ModulePagePath $ModulePagePath `
                    -ErrorAction 'Stop'
            }

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
                Write-Verbose 'Unloading PlatyPS module.'
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
