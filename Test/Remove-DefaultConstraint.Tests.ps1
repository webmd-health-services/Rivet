
& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

function Init
{
    Start-RivetTest
}

function Reset
{
    Stop-RivetTest
}

Describe 'Remove-DefaultConstraint' {
    BeforeEach { Init }
    AfterEach { Reset }

    It 'should remove default constraint' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'AddDefaultConstraint' {
            Int 'DefaultConstraintMe' -NotNull
        }
    
        Add-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe' -Expression 101
        Remove-DefaultConstraint 'AddDefaultConstraint' -Name '$(New-RTConstraintName -Default 'AddDefaultConstraint' 'DefaultConstraintMe')'
    }
    
    function Pop-Migration()
    {
        Remove-Table 'AddDefaultConstraint'
    }
"@ | New-TestMigration -Name 'RemoveDefaultConstraint'
        Invoke-RTRivet -Push 'RemoveDefaultConstraint'
        (Get-DefaultConstraint 'DF_AddDefaultConstraint_DefaultConstraintMe') | Should -BeNullOrEmpty
    }
    
    It 'should quote default constraint name' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'Remove-DefaultConstraint' {
            Int 'DefaultConstraintMe' -NotNull
        }
    
        Add-DefaultConstraint -TableName 'Remove-DefaultConstraint' -ColumnName 'DefaultConstraintMe' -Expression 101
        Remove-DefaultConstraint -TableName 'Remove-DefaultConstraint' -Name '$(New-RTConstraintName -Default 'Remove-DefaultConstraint' 'DefaultConstraintMe')'
    }
    
    function Pop-Migration()
    {
        Remove-Table 'Remove-DefaultConstraint'
    }
"@ | New-TestMigration -Name 'RemoveDefaultConstraint'
        Invoke-RTRivet -Push 'RemoveDefaultConstraint'
        (Get-DefaultConstraint 'DF_Remove-DefaultConstraint_DefaultConstraintMe') | Should -BeNullOrEmpty
    }
    
    
    It 'should remove default constraint with default name' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'AddDefaultConstraint' {
            Int 'DefaultConstraintMe' -NotNull
        }
    
        Add-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe' -Expression 101
        Remove-DefaultConstraint 'AddDefaultConstraint' 'DefaultConstraintMe'
    }
    
    function Pop-Migration()
    {
        Remove-Table 'AddDefaultConstraint'
    }
"@ | New-TestMigration -Name 'RemoveDefaultConstraint'
        Invoke-RTRivet -Push 'RemoveDefaultConstraint'
        (Get-DefaultConstraint 'DF_AddDefaultConstraint_DefaultConstraintMe') | Should -BeNullOrEmpty
    }
}
