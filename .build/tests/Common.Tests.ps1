#requires -Modules Pester
#.SYNOPSIS
#   Performs tests to make sure the PowerShell module works as intended
Describe 'Common cmdlets' {
    Context 'Merge-Hashtable' {
        It 'should merge simple hashes' {
            Merge-Hashtable -BaseObject @{key1 = 'val1' } -InputObject @{key1 = 'val2' } | Select-Object -ExpandProperty Values | Should -Be 'val2'
        }
        It 'should perform deep merges' {
            {
                $ComplexHash = @{
                    key1        = 'val1'
                    key2        = 'val2'
                    arr1        = @('a', 'b', 'c')
                    nested_hash = @{
                        nested_hash_key1 = 'val3'
                        nested_hash_key2 = 'val4'
                        nested_hash_arr1 = @('a', 'b', 'c')
                    }
                }
                
                $ComplexHash2 = @{
                    key1        = 'val3'
                    key2        = 'val4'
                    arr1        = @('a', 'b', 'd')
                    nested_hash = @{
                        nested_hash_key1 = 'val1'
                        nested_hash_key2 = 'val2'
                        nested_hash_arr1 = @('a', 'b', 'd')
                    }
                }
                Merge-Hashtable -BaseObject $ComplexHash -InputObject $ComplexHash2
            } | Should -not -Throw
        }
        It 'should fail to deep merge inconsistent keys' {
            {
                $Hash1 = @{
                    key1 = 'val1'
                    arr1 = @('a', 'b', 'c')
                }
                $Hash2 = @{
                    key1 = 'val1'
                    arr1 = @{'test' = $true }
                }
                Merge-Hashtable -BaseObject $Hash1 -InputObject $Hash2 -ErrorAction 'stop'
            } | Should -Throw
        }
    }
}