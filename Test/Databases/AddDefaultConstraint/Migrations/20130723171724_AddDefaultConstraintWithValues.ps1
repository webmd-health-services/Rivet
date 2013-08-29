function Push-Migration()
{
    Add-Table -Name 'AddDefaultConstraint' {
        New-Column 'DefaultConstraintMe' -Int -NotNull
    }

    Add-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe' -Expression 101 -WithValues
}

function Pop-Migration()
{
}
