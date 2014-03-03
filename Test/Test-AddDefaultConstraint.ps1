
function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RivetTest' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
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
}
'@ | New-Migration -Name 'AddDefaultConstraint'

    Invoke-Rivet -Push 'AddDefaultConstraint'
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
}
'@ | New-Migration -Name 'AddDefaultConstraintWithValues'

    $Error.Clear()
    Invoke-Rivet -Push 'AddDefaultConstraintWithValues'
    Assert-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe'
    Assert-Equal 0 $Error.Count
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
}
'@ | New-Migration -Name 'AddDefaultConstraintQuotesName'

    Invoke-Rivet -Push 'AddDefaultConstraintQuotesName'
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
}
'@ | New-Migration -Name 'AddDefaultConstraintOptionalParameterNames'

    Invoke-Rivet -Push 'AddDefaultConstraintOptionalParameterNames'
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
}
'@ | New-Migration -Name 'AddDefaultConstraintOptionalParameterNames'

    Invoke-Rivet -Push 'AddDefaultConstraintOptionalParameterNames'
    Assert-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe' -Name 'Optional'
}