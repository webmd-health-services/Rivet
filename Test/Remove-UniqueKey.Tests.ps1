
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

function Init
{
    Start-RivetTest
}

function Reset
{
    Stop-RivetTest
}

Describe 'Remove-UniqueKey' {
    BeforeEach { Init }
    AfterEach { Reset }

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
