
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

Describe 'Remove-Index' {
    BeforeEach { Init }
    AfterEach { Reset }

    It 'should remove index' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'AddIndex' {
            Int 'IndexMe' -NotNull
        }
    
        #Add an Index to 'IndexMe'
        Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe'
    
        Remove-Index 'AddIndex' -Name '$(New-RTConstraintName -Index 'AddIndex' 'IndexMe')'
    }
    
    function Pop-Migration()
    {
        Remove-Table 'AddIndex'
    }
"@ | New-TestMigration -Name 'RemoveIndex'
    
        Invoke-RTRivet -Push 'RemoveIndex'
        (Test-Table 'AddIndex') | Should -BeTrue
        (Test-Column -Name 'IndexMe' -TableName 'AddIndex') | Should -BeTrue
        (Test-Index -TableName 'AddIndex' -ColumnName 'IndexMe') | Should -BeFalse
    }
    
    It 'should quote index name' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'Remove-Index' {
            Int 'IndexMe' -NotNull
        }
    
        Add-Index -TableName 'Remove-Index' -ColumnName 'IndexMe'
        Remove-Index -TableName 'Remove-Index' -Name '$(New-RTConstraintName -Index 'Remove-Index' 'IndexMe')'
    }
    
    function Pop-Migration()
    {
        Remove-Table 'Remove-Index'
    }
"@ | New-TestMigration -Name 'RemoveIndex'
    
        Invoke-RTRivet -Push 'RemoveIndex'
        (Test-Index -TableName 'Remove-Index' -ColumnName 'IndexMe') | Should -BeFalse
    }
    
    
    It 'should remove unique index' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'AddIndex' {
            Int 'IndexMe' -NotNull
        }
    
        #Add an Index to 'IndexMe'
        Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Unique
        Remove-Index 'AddIndex' -Name '$(New-RTConstraintName -Index -Unique 'AddIndex' 'IndexMe')'
    }
    
    function Pop-Migration()
    {
        Remove-Table 'AddIndex'
    }
"@ | New-TestMigration -Name 'RemoveIndex'
    
        Invoke-RTRivet -Push 'RemoveIndex'
        (Test-Table 'AddIndex') | Should -BeTrue
        (Test-Column -Name 'IndexMe' -TableName 'AddIndex') | Should -BeTrue
        (Test-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Unique) | Should -BeFalse
    }
    
    It 'should remove index with default name' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'AddIndex' {
            Int 'IndexMe' -NotNull
            Int 'IndexMeUnique' -NotNull
        }
    
        #Add an Index to 'IndexMe'
        Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe'
        Add-Index -TableName 'AddIndex' -ColumnName 'IndexMeUnique' -Unique
    
        Remove-Index 'AddIndex' 'IndexMe'
        Remove-Index 'AddIndex' 'IndexMeUnique' -Unique
    }
    
    function Pop-Migration()
    {
        Remove-Table 'AddIndex'
    }
"@ | New-TestMigration -Name 'RemoveIndex'
    
        Invoke-RTRivet -Push 'RemoveIndex'
        (Test-Table 'AddIndex') | Should -BeTrue
        (Test-Column -Name 'IndexMe' -TableName 'AddIndex') | Should -BeTrue
        (Test-Column -Name 'IndexMeUnique' -TableName 'AddIndex') | Should -BeTrue
        (Test-Index -TableName 'AddIndex' -ColumnName 'IndexMe') | Should -BeFalse
        (Test-Index -TableName 'AddIndex' -ColumnName 'IndexMeUnique') | Should -BeFalse
    }
    
}
