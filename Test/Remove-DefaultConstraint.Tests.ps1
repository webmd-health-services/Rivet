
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'Remove-DefaultConstraint' {
    BeforeEach { Start-RivetTest }
    AfterEach { Stop-RivetTest }

    It 'should remove default constraint' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'AddDefaultConstraint' {
            Int 'DefaultConstraintMe' -NotNull
        }

        Add-DefaultConstraint -TableName 'AddDefaultConstraint' -Name 'DF_One' -ColumnName 'DefaultConstraintMe' -Expression 101
        Remove-DefaultConstraint 'AddDefaultConstraint' -Name 'DF_One' -ColumnName 'DefaultConstraintMe'
    }

    function Pop-Migration()
    {
        Remove-Table 'AddDefaultConstraint'
    }
"@ | New-TestMigration -Name 'RemoveDefaultConstraint'
        Invoke-RTRivet -Push 'RemoveDefaultConstraint'
        (Get-DefaultConstraint 'DF_One') | Should -BeNullOrEmpty
    }

    It 'should quote default constraint name' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'Remove-DefaultConstraint' {
            Int 'DefaultConstraintMe' -NotNull
        }

        Add-DefaultConstraint -TableName 'Remove-DefaultConstraint' -Name 'DF_Two' -ColumnName 'DefaultConstraintMe' -Expression 101
        Remove-DefaultConstraint -TableName 'Remove-DefaultConstraint' -Name 'DF_Two' -ColumnName 'DefaultConstraintMe'
    }

    function Pop-Migration()
    {
        Remove-Table 'Remove-DefaultConstraint'
    }
"@ | New-TestMigration -Name 'RemoveDefaultConstraint'
        Invoke-RTRivet -Push 'RemoveDefaultConstraint'
        (Get-DefaultConstraint 'DF_Two') | Should -BeNullOrEmpty
    }


    It 'should remove default constraint with default name' {
        @"
    function Push-Migration()
    {
        Add-Table -Name 'AddDefaultConstraint' {
            Int 'DefaultConstraintMe' -NotNull
        }

        Add-DefaultConstraint -TableName 'AddDefaultConstraint' -Name 'DF_Three' -ColumnName 'DefaultConstraintMe' -Expression 101
        Remove-DefaultConstraint -TableName 'AddDefaultConstraint' -Name 'DF_Three' -ColumnName 'DefaultConstraintMe'
    }

    function Pop-Migration()
    {
        Remove-Table 'AddDefaultConstraint'
    }
"@ | New-TestMigration -Name 'RemoveDefaultConstraint'
        Invoke-RTRivet -Push 'RemoveDefaultConstraint'
        (Get-DefaultConstraint 'DF_Three') | Should -BeNullOrEmpty
    }
}
