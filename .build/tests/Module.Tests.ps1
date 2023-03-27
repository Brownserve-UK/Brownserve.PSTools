#requires -Modules Pester
#.SYNOPSIS
#   Performs tests to make sure the PowerShell module works as intended
BeforeAll {
    # Remove the module we've already imported 😬
    Remove-Module Brownserve.PSTools -Verbose:$false
}
Describe 'ModuleImport' {
    Context 'When Brownserve.PSTools is imported' {
        It 'should not throw any exception' {
            { Join-Path $global:BrownserveBuiltModuleDirectory -ChildPath "Brownserve.PSTools.psd1" | Import-Module -Force -Verbose:$false } | Should -not -Throw 
        }
        It 'should have cmdlets on the path' -TestCases @(
            @{Filter = 'Get-OpenPullRequests'; Expected = 'Get-OpenPullRequests' },
            @{Filter = '*Teamcity*'; Expected = @('Publish-TeamcityArtifact', 'Set-TeamcityBuildNumber', 'Write-TeamcityBuildProblem', 'Write-TeamcityStatus')}
        ) {
            param ($Filter, $Expected)
            $Commands = Get-Command -name $Filter
            $Commands.Name | Should -Be $Expected
        }
    }
}