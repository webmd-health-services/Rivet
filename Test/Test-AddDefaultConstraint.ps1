
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldAddDefaultConstraint
{
    @'
function Push-Migration()
{
    # Yes.  Spaces in the name so we check the name gets quoted.
    Add-Table -Name 'AddDefaultConstraint' {
        Int 'Default Constraint Me' -NotNull
    }

    Add-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'Default Constraint Me' -Expression 101

}

function Pop-Migration()
{
    Remove-Table 'AddDefaultConstraint'
}
'@ | New-Migration -Name 'AddDefaultConstraint'

    Invoke-RTRivet -Push 'AddDefaultConstraint'
    Assert-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'Default Constraint Me'

}

function Test-ShouldAddDefaultConstraintWithValues
{
    @'
function Push-Migration()
{
    Add-Table -Name 'AddDefaultConstraint' {
        Int 'DefaultConstraintMe' -NotNull
    }

    Add-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe' -Expression 101 -WithValues
}

function Pop-Migration()
{
    Remove-Table 'AddDefaultConstraint'
}
'@ | New-Migration -Name 'AddDefaultConstraintWithValues'

    Invoke-RTRivet -Push 'AddDefaultConstraintWithValues'
    Assert-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe'
    Assert-NoError
}


function Test-ShouldAddDefaultConstraintQuotesName
{
    @'
function Push-Migration()
{
    Add-Table -Name 'Add-DefaultConstraint' {
        Int 'DefaultConstraintMe' -NotNull
    }

    Add-DefaultConstraint -TableName 'Add-DefaultConstraint' -ColumnName 'DefaultConstraintMe' -Expression 101

}

function Pop-Migration()
{
    Remove-Table 'Add-DefaultConstraint'
}
'@ | New-Migration -Name 'AddDefaultConstraintQuotesName'

    Invoke-RTRivet -Push 'AddDefaultConstraintQuotesName'
    Assert-DefaultConstraint -TableName 'Add-DefaultConstraint' -ColumnName 'DefaultConstraintMe'

}

function Test-ShouldSupportOptionalParameterNames
{
    @'
function Push-Migration()
{
    Add-Table -Name 'AddDefaultConstraint' {
        Int 'DefaultConstraintMe' -NotNull
    }

    Add-DefaultConstraint 'AddDefaultConstraint' 'DefaultConstraintMe' 101

}

function Pop-Migration()
{
    Remove-Table 'AddDefaultConstraint'
}
'@ | New-Migration -Name 'AddDefaultConstraintOptionalParameterNames'

    Invoke-RTRivet -Push 'AddDefaultConstraintOptionalParameterNames'
    Assert-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe'

}

function Test-ShouldSupportOptionalConstraintName
{
    @'
function Push-Migration()
{
    Add-Table -Name 'AddDefaultConstraint' {
        Int 'DefaultConstraintMe' -NotNull
    }

    Add-DefaultConstraint 'AddDefaultConstraint' 'DefaultConstraintMe' 101 -Name 'Optional'

}

function Pop-Migration()
{
    Remove-Table 'AddDefaultConstraint'
}
'@ | New-Migration -Name 'AddDefaultConstraintOptionalParameterNames'

    Invoke-RTRivet -Push 'AddDefaultConstraintOptionalParameterNames'
    Assert-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe' -Name 'Optional'
}
