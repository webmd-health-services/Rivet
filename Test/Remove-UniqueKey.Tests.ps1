
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

Describe 'Remove-UniqueKey' {
    BeforeEach {
        Start-RivetTest
    }
    
    AfterEach {
        Stop-RivetTest -Pop
    }
    
    It 'should remove unique key' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'RemoveUniqueKey' {
            Int 'RemoveMyUniqueKey' -NotNull
        }
    
        #Add an Index to 'IndexMe'
        Add-UniqueKey -TableName 'RemoveUniqueKey' -ColumnName 'RemoveMyUniqueKey'
    
        #Remove Index
        Remove-UniqueKey -TableName 'RemoveUniqueKey' -Name '$(New-RTConstraintName -UniqueKey 'RemoveUniqueKey' 'RemoveMyUniqueKey')'
    }
    
    function Pop-Migration()
    {
        Remove-Table 'RemoveUniqueKey'
    }
"@ | New-TestMigration -Name 'RemoveUniqueKey'
        Invoke-RTRivet -Push 'RemoveUniqueKey'
        (Test-UniqueKey -TableName 'RemoveUniqueKey' -ColumnName 'RemoveMyUniqueKey') | Should -BeFalse
    }
    
    It 'should remove unique key' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'Remove-UniqueKey' {
            Int 'RemoveMyUniqueKey' -NotNull
        }
    
        Add-UniqueKey -TableName 'Remove-UniqueKey' -ColumnName 'RemoveMyUniqueKey'
        Remove-UniqueKey -TableName 'Remove-UniqueKey' -Name '$(New-RTConstraintName -UniqueKey 'Remove-UniqueKey' 'RemoveMyUniqueKey')'
    }
    
    function Pop-Migration()
    {
        Remove-Table 'Remove-UniqueKey'
    }
"@ | New-TestMigration -Name 'RemoveUniqueKey'
        Invoke-RTRivet -Push 'RemoveUniqueKey'
        (Test-UniqueKey -TableName 'Remove-UniqueKey' -ColumnName 'RemoveMyUniqueKey') | Should -BeFalse
    
    }
    
    It 'should remove unique key with default name' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'RemoveUniqueKey' {
            Int 'RemoveMyUniqueKey' -NotNull
        }
    
        #Add an Index to 'IndexMe'
        Add-UniqueKey -TableName 'RemoveUniqueKey' -ColumnName 'RemoveMyUniqueKey'
    
        #Remove Index
        Remove-UniqueKey -TableName 'RemoveUniqueKey' 'RemoveMyUniqueKey'
    }
    
    function Pop-Migration()
    {
        Remove-Table 'RemoveUniqueKey'
    }
"@ | New-TestMigration -Name 'RemoveUniqueKey'
        Invoke-RTRivet -Push 'RemoveUniqueKey'
        (Test-UniqueKey -TableName 'RemoveUniqueKey' -ColumnName 'RemoveMyUniqueKey') | Should -BeFalse
    
    }
    
}
