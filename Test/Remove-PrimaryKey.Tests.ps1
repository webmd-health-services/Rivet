
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

Describe 'Remove-PrimaryKey' {
    BeforeEach {
        Start-RivetTest
        @'
    function Push-Migration()
    {
        Add-Table -Name 'PrimaryKey' {
            Int 'id' -NotNull
        }
    }
    
    function Pop-Migration()
    {
        Remove-Table -Name 'PrimaryKey'
    }
'@ | New-TestMigration -Name 'CreateTable'
    }
    
    AfterEach {
        Stop-RivetTest -Pop
    }
    
    It 'should remove primary key' {
        @"
    function Push-Migration()
    {
        Add-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id'
    }
    
    function Pop-Migration()
    {
        Remove-PrimaryKey -TableName 'PrimaryKey' -Name '$(New-RTConstraintName -PrimaryKey 'PrimaryKey')'
    }
"@ | New-TestMigration -Name 'SetandRemovePrimaryKey'
        Invoke-RTRivet -Push
        (Test-Table 'PrimaryKey') | Should -BeTrue
        Assert-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id'
    
        Invoke-RTRivet -Pop
        (Test-PrimaryKey -TableName 'PrimaryKey') | Should -BeFalse
    }
    
    It 'should quote primary key name' {
        @"
    function Push-Migration()
    {
        Add-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id' -Name 'Primary Key'
    }
    
    function Pop-Migration()
    {
        Remove-PrimaryKey -TableName 'PrimaryKey' -Name 'Primary Key'
    }
"@ | New-TestMigration -Name 'SetandRemovePrimaryKey'
        Invoke-RTRivet -Push
        Invoke-RTRivet -Pop
        (Test-PrimaryKey -TableName 'Remove-PrimaryKey') | Should -BeFalse
    }
    
    It 'should remove primary key with default name' {
    @"
    function Push-Migration()
    {
        Add-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id'
    }
    
    function Pop-Migration()
    {
        Remove-PrimaryKey -TableName 'PrimaryKey'
    }
"@ | New-TestMigration -Name 'SetandRemovePrimaryKey'
        Invoke-RTRivet -Push
        (Test-Table 'PrimaryKey') | Should -BeTrue
        Assert-PrimaryKey -TableName 'PrimaryKey' -ColumnName 'id'
    
        Invoke-RTRivet -Pop
        (Test-PrimaryKey -TableName 'PrimaryKey') | Should -BeFalse
    }
    
}
