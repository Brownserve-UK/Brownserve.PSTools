#requires -Modules Pester
#.SYNOPSIS
#   Performs tests to make sure the modules help/documentation is up to date

Describe 'Documentation' {
    Context 'Markdown Files' {
        It 'should have a README.md file' {
            $ReadmePath = Join-Path -Path $Global:BrownserveRepoRootDirectory -ChildPath 'README.md'
            Test-Path -Path $ReadmePath | Should -Be $true
        }
        It 'should have a CHANGELOG.md file' {
            $ChangelogPath = Join-Path -Path $Global:BrownserveRepoRootDirectory -ChildPath 'CHANGELOG.md'
            Test-Path -Path $ChangelogPath | Should -Be $true
        }
        It 'should have a LICENSE file' {
            $LicensePath = Join-Path -Path $Global:BrownserveRepoRootDirectory -ChildPath 'LICENSE'
            Test-Path -Path $LicensePath | Should -Be $true
        }
        It 'should have a markdown file for each cmdlet' {
            $CmdletNames = Get-Command -Module Brownserve.PSTools | Select-Object -ExpandProperty Name
            $CmdletNames | ForEach-Object {
                $CmdletName = $_
                $CmdletPath = Join-Path -Path $Global:BrownserveRepoDocsDirectory -ChildPath "Brownserve.PSTools" -AdditionalChildPath "$CmdletName.md"
                Test-Path -Path $CmdletPath | Should -Be $true
            }
        }
        It 'should not have any incomplete sections in markdown files' {
            $MarkdownFiles = Get-ChildItem -Path (Join-Path $Global:BrownserveRepoDocsDirectory -ChildPath "Brownserve.PSTools")  -Filter *.md -Recurse
            $MarkdownFiles | ForEach-Object {
                $MarkdownFile = $_
                $MarkdownFileContent = Get-Content -Path $MarkdownFile.FullName
                $MarkdownFileContent | Should -Not -Match '{{ .* }}'
            }
        }
        # Disabled for now until we work out how we want to specify this test to only run on the main/dev branches
        # It 'should have matching version numbers in the module page' {
        #     $ModuleVersion = $Global:NugetPackageVersion
        #     $ModuleVersionPath = Join-Path -Path $Global:BrownserveRepoDocsDirectory -ChildPath "Brownserve.PSTools.md"
        #     $ModuleVersionContent = Get-Content -Path $ModuleVersionPath
        #     $ModuleVersionContent | Should -Contain "Help Version: $ModuleVersion"
        # }
    }
}