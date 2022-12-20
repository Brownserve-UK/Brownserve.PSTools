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

        # Whether or not to ignore cmdlet compatibility when generating docs
        [Parameter(Mandatory = $false)]
        [bool]
        $IgnoreCmdletCompatibility = $true,

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
        # Ensure the PlatyPS module is loaded
        try
        {
            $PlatyPSCheck = Get-Module -Name 'PlatyPS'
            if (!$PlatyPSCheck)
            {
                Import-Module 'PlatyPS' -Force -ErrorAction 'Stop'
            }
        }
        catch
        {
            throw "Failed to import PlatyPS module.`n$($_.Exception.Message)"
        }

        $Return = @()
    }
    
    process
    {
        try
        {
            $ModuleDirectory = Get-Item (Split-Path $ModulePath) | Convert-Path
        }
        catch
        {
            throw "Unable to determine module directory.`n$($_.Exception.Message)"
        }
        # First if the module we want to make docs for is not already loaded then we should ensure that it is
        try
        {
            $ModuleLoaded = Get-Module -Name $ModuleName
        }
        catch
        {
            # do nothing, probably isn't loaded yet
        }
        # Sometimes we may want to unload the module and reload it, especially if we've been working on changes as this ensures anything new will be picked up.
        if ($ModuleLoaded -and $ReloadModule)
        {
            Write-Verbose 'reloading module'
            try
            {
                Remove-Module $ModuleName -Force -ErrorAction 'Stop'
            }
            catch
            {
                throw "Unable to unload module '$ModuleName'.`n$($_.Exception.Message)"
            }
        }
        <# 
            Some of the modules we write contain cmdlets that are OS specific (e.g. Install-Chocolatey package on Windows) and we have logic that prevents these from being loaded
            on incompatible operating systems.
            This results in PlatyPS failing to generate documentation for these cmdlets, so we set our super secret special flag that will ensure all cmdlets get loaded even if they
            are not compatible with our OS.
        #>
        if ($IgnoreCmdletCompatibility)
        {
            $CurrentIgnoreState = $global:IgnoreCmdletCompatibility
            $global:IgnoreCmdletCompatibility = $true
        }
        if (!$ModuleLoaded -or $ReloadModule)
        {
            try
            {
                Import-Module -Name $ModulePath -Force -ErrorAction 'Stop' 
            }
            catch
            {
                throw "Failed to import module '$ModuleName' from $ModulePath.`n$($_.Exception.Message)"
            }
            finally
            {
                $global:IgnoreCmdletCompatibility = $CurrentIgnoreState
            }
        }
        # Check that the destination exists and if not create it
        try
        {
            $OutputDirCheck = Get-Item $DocumentationPath -ErrorAction 'Stop' | Where-Object { $_.PSIsContainer }
            if (!$OutputDirCheck)
            {
                throw "Documentation path '$DocumentationPath' does not exist or is not a directory."
            }
            # Create a directory with the name of module to be used to store the docs
            $ModuleDocumentationDirectory = Join-Path $DocumentationPath $ModuleName
            if (!(Test-Path $ModuleDocumentationDirectory))
            {
                New-Item $ModuleDocumentationDirectory -ItemType Directory -ErrorAction 'Stop' | Out-Null
            }
        }
        catch
        {
            throw "Failed to create module documentation directory.`n$($_.Exception.Message)"
        }

        # We store out documentation slightly differently depending on whether or not we're including documentation for the modules private cmdlets
        if ($IncludePrivate)
        {
            $PublicCmdletDocPath = Join-Path $ModuleDocumentationDirectory 'Public'
            $PrivateCmdletDocPath = Join-Path $ModuleDocumentationDirectory 'Private'
            $ModulePagePath = Join-Path $ModuleDocumentationDirectory "$($ModuleName).md"
            # When documenting private functions we need to temporarily create a module that we can import and use
            $PrivateModuleName = "$($ModuleName)Private"
            try
            {
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
            }
            catch
            {
                throw "Failed to build temporary module for private cmdlets.`n$($_.Exception.Message)"
            }

            try
            {
                $TempPrivateModule = New-BrownserveTemporaryFile `
                    -FileName $PrivateModuleName `
                    -FileExtension '.psm1' `
                    -Content $PrivateModuleContent `
                    -ErrorAction 'Stop'
            }
            catch
            {
                throw "Failed to create the temporary module for private cmdlets.`n$($_.Exception.Message)"
            }
            try
            {
                <# 
                    the -Global param is needed here due to some quirk in PlatyPS/PowerShell, if it's not used it doesn't seem to pick up that the module has been loaded :/
                #>
                Import-Module $TempPrivateModule -Force -ErrorAction 'Stop' -Global
            }
            catch
            {
                throw "Failed to import the temporary module for private cmdlets.`n$($_.Exception.Message)"
            }
            if (!(Test-Path $PrivateCmdletDocPath))
            {
                $NewPrivateDocsParams = @{
                    Module                = $PrivateModuleName
                    OutputFolder          = $PrivateCmdletDocPath
                    AlphabeticParamsOrder = $tue
                }
                if ($IgnoreDontShow)
                {
                    $NewPrivateDocsParams.Add('ExcludeDontShow', $true)
                }
                try
                {
                    New-Item $PrivateCmdletDocPath -ItemType Directory -ErrorAction 'Stop' | Out-Null
                }
                catch
                {
                    Remove-Module $TempPrivateModule -Force -ErrorAction 'SilentlyContinue'
                    throw "Failed to create private cmdlet directory.`n$($_.Exception.Message)"
                }
                try
                {
                    New-MarkdownHelp @NewPrivateDocsParams -ErrorAction 'Stop' | Out-Null
                }
                catch
                {
                    throw "Failed to create private cmdlet documentation.`n$($_.Exception.Message)"
                }
                finally
                {
                    Remove-Module $PrivateModuleName -Force -ErrorAction 'SilentlyContinue'
                    Remove-Item $TempPrivateModule -Force -ErrorAction 'SilentlyContinue'
                }
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
                try
                {
                    Update-MarkdownHelpModule @UpdatePrivateDocsParams -ErrorAction 'Stop' | Out-Null
                }
                catch
                {
                    throw "Failed to update private cmdlet documentation for $ModuleName.`n$($_.Exception.Message)"
                }
            }
        }
        else
        {
            $PublicCmdletDocPath = $ModuleDocumentationDirectory
            $ModulePagePath = Join-Path $DocumentationPath "$($ModuleName).md"
        }

        if (!(Test-Path $PublicCmdletDocPath))
        {
            try
            {
                New-Item $PublicCmdletDocPath -ItemType Directory -ErrorAction 'Stop' | Out-Null
            }
            catch
            {
                throw "Failed to create public cmdlet directory.`n$($_.Exception.Message)"
            }
        }

        $PlatyParams = @{
            AlphabeticParamsOrder = $true
            ModulePagePath        = $ModulePagePath
        }

        if ($IgnoreDontShow)
        {
            $PlatyParams.Add('ExcludeDontShow', $true)
        }

        # Check if we've already got some docs for this module
        try
        {
            $ExistingDocs = Get-Item $ModulePagePath
        }
        catch
        {
            # Don't do anything, probably doesn't exist
        }

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
            try
            {
                # Mute warnings as cmdlets that are not yet documented will cause complaints 🙄
                New-MarkdownHelp @NewDocsParams -ErrorAction 'Stop' -WarningAction 'SilentlyContinue' | Out-Null
            }
            catch
            {
                throw "Failed to build new module documentation for $ModuleName.`n$($_.Exception.Message)"
            }
        }
        else
        {
            $UpdateDocsParams = $PlatyParams
            $UpdateDocsParams.Add('Path', $PublicCmdletDocPath)
            $UpdateDocsParams.Add('RefreshModulePage', $true)
            $UpdateDocsParams.Add('UpdateInputOutput', $true)
            $UpdateDocsParams.Add('Force', $true) # This is a poorly named parameter it actually just deletes cmdlets that have been removed.
            # For some reason we get a lot of warnings when using the update cmdlet that make no sense, so just mute them for now.
            try
            {
                Update-MarkdownHelpModule @UpdateDocsParams -ErrorAction 'Stop' -WarningAction 'SilentlyContinue' | Out-Null
            }
            catch
            {
                throw "Failed to update module documentation for $ModuleName.`n$($_.Exception.Message)"
            }
        }

        <#
            Currently PlatyPS expects the Module page to be in the same directory as the help files and as such hard-codes the links :(
            To get around this we'll import the page content and then adjust the links using regex to point them at the right place.
            We may be able to remove the below once this issue is resolved: https://github.com/PowerShell/platyPS/issues/451
        #>
        try
        {
            $ModulePageContent = Get-Content $ModulePagePath -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to get help content from '$ModulePagePath'."
        }
        try
        {
            $ModulePageAdjustment = Split-Path $PublicCmdletDocPath -Leaf
            $SanitizedModulePageContent = $ModulePageContent -replace '\(([\w|\d]*-[\w|\d]*.md)\)', "(./$ModulePageAdjustment/`$1)"
            Set-Content $ModulePagePath -Value $SanitizedModulePageContent -ErrorAction 'Stop'
        }
        catch
        {
            throw "Failed to sanitize documentation links in $ModulePagePath.`n$($_.Exception.Message)"
        }
        # Create some sensible return so that we can pipe it into a cmdlet to update the MALM
        $Return += [pscustomobject]@{
            ModuleDirectory   = $ModuleDirectory
            HelpLanguage      = 'en-US' # Hardcoded as we only support the one atm
            DocumentationPath = ($PublicCmdletDocPath | Convert-Path) # Only the public cmdlets need to be documented
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