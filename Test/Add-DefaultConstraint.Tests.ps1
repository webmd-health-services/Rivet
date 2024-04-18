
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'Add-DefaultConstraint' {
    BeforeEach { Start-RivetTest }
    AfterEach { Stop-RivetTest }

    It 'should add default constraint' {
        @'
    function Push-Migration()
    {
        # Yes.  Spaces in the name so we check the name gets quoted.
        Add-Table -Name 'AddDefaultConstraint' {
            Int 'Default Constraint Me' -NotNull
        }

        Add-DefaultConstraint -TableName 'AddDefaultConstraint' `
                              -ColumnName 'Default Constraint Me' `
                              -Expression 101 `
                              -Name 'DF_AddDefaultConstraint_Default Constraint Me'
    }

    function Pop-Migration()
    {
        Remove-Table 'AddDefaultConstraint'
    }
'@ | New-TestMigration -Name 'AddDefaultConstraint'

        Invoke-RTRivet -Push 'AddDefaultConstraint'
        Assert-DefaultConstraint -Name 'DF_AddDefaultConstraint_Default Constraint Me'
    }

    It 'should add default constraint with values' {
        @'
    function Push-Migration()
    {
        Add-Table -Name 'AddDefaultConstraint' {
            Int 'DefaultConstraintMe' -NotNull
        }

        Add-DefaultConstraint -TableName 'AddDefaultConstraint' `
                              -ColumnName 'DefaultConstraintMe' `
                              -Expression 101 `
                              -WithValues `
                              -Name 'DF_AddDefaultConstraint_DefaultConstraintMe'
    }

    function Pop-Migration()
    {
        Remove-Table 'AddDefaultConstraint'
    }
'@ | New-TestMigration -Name 'AddDefaultConstraintWithValues'

        Invoke-RTRivet -Push 'AddDefaultConstraintWithValues'
        Assert-DefaultConstraint -Name 'DF_AddDefaultConstraint_DefaultConstraintMe'
        $Global:Error.Count | Should -Be 0
    }


    It 'should add default constraint quotes name' {
        @'
    function Push-Migration()
    {
        Add-Table -Name 'Add-DefaultConstraint' {
            Int 'DefaultConstraintMe' -NotNull
        }

        Add-DefaultConstraint -TableName 'Add-DefaultConstraint' `
                              -ColumnName 'DefaultConstraintMe' `
                              -Expression 101 `
                              -Name 'DF_Add-DefaultConstraint_DefaultConstraintMe'

    }

    function Pop-Migration()
    {
        Remove-Table 'Add-DefaultConstraint'
    }
'@ | New-TestMigration -Name 'AddDefaultConstraintQuotesName'

        Invoke-RTRivet -Push 'AddDefaultConstraintQuotesName'
        Assert-DefaultConstraint -Name 'DF_Add-DefaultConstraint_DefaultConstraintMe'

    }

    It 'should support optional parameter names' {
        @'
    function Push-Migration()
    {
        Add-Table -Name 'AddDefaultConstraint' {
            Int 'DefaultConstraintMe' -NotNull
        }

        Add-DefaultConstraint 'AddDefaultConstraint' `
                              'DefaultConstraintMe' `
                              101 `
                              -Name 'DF_AddDefaultConstraint_DefaultConstraintMe'

    }

    function Pop-Migration()
    {
        Remove-Table 'AddDefaultConstraint'
    }
'@ | New-TestMigration -Name 'AddDefaultConstraintOptionalParameterNames'

        Invoke-RTRivet -Push 'AddDefaultConstraintOptionalParameterNames'
        Assert-DefaultConstraint -Name 'DF_AddDefaultConstraint_DefaultConstraintMe'
    }

    It 'should use the user''s constraint name' {
        @'
    function Push-Migration()
    {
        Add-Table -Name 'AddDefaultConstraint' {
            Int 'DefaultConstraintMe' -NotNull
        }

        Add-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe' -Expression 101 -Name 'Optional'

    }

    function Pop-Migration()
    {
        Remove-Table 'AddDefaultConstraint'
    }
'@ | New-TestMigration -Name 'AddDefaultConstraintOptionalParameterNames'

        Invoke-RTRivet -Push 'AddDefaultConstraintOptionalParameterNames'
        Assert-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe' -Name 'Optional'
    }
}
