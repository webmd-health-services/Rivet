function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RenameTable' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldRenameTable
{

@'
function Push-Migration
{
    Add-Table -Name 'AddTable' -Description 'Testing Add-Table migration' -Column {
        VarChar 'varchar' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        BigInt 'id' -Identity
    } -Option 'data_compression = none'

    Rename-Table 'AddTable' 'RenameTable'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'RenameTable'

    Invoke-Rivet -Push 'RenameTable'

    Assert-Table 'RenameTable' -Description 'Testing Add-Table migration'
    Assert-Column -Name 'varchar' 'varchar' -NotNull -Description 'varchar(max) constraint DF_AddTable_varchar default default' -TableName 'RenameTable'
    Assert-Column -Name 'id' 'bigint' -NotNull -Seed 1 -Increment 1 -TableName 'RenameTable'

}

function Test-ShouldRenameColumn
{

@'
function Push-Migration
{
    Add-Table -Name 'Table' -Column {
        VarChar 'buzz' -Max
        BigInt 'id' -Identity
    } -Option 'data_compression = none'

    Rename-Column 'Table' 'buzz' 'fizz'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'RenameColumn'

    Invoke-Rivet -Push 'RenameColumn'

    Assert-Table 'Table'
    Assert-Column -Name 'fizz' -TableName 'Table' -DataType 'varchar'
    Assert-Column -Name 'id' 'bigint' -NotNull -Seed 1 -Increment 1 -TableName 'Table'

}

function Test-ShouldRenameIndex
{

@'
function Push-Migration
{
    Add-Table -Name 'AddIndex' {
        Int 'IndexMe' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe'
    Rename-Index -TableName 'AddIndex' -Name 'IX_AddIndex_IndexMe' -NewName 'IX_AddIndex_Renamed'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'RenameIndex'

    Invoke-Rivet -Push 'RenameIndex'

    ##Assert Table and Column
    Assert-True (Test-Table 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe' -TableName 'AddIndex')

    ##Assert Index
    Assert-Index -TableName 'AddIndex' -ColumnName 'Renamed'

}

function Test-ShouldRenameConstraint
{

@'
function Push-Migration
{
    Add-Table -Name 'Source' {
        Int 'source_id' -NotNull
    }

    Add-Table -Name 'Reference' {
        Int 'reference_id' -NotNull
    }

    Add-PrimaryKey -TableName 'Reference' -ColumnName 'reference_id'
    Add-ForeignKey -TableName 'Source' -ColumnName 'source_id' -References 'Reference' -ReferencedColumn 'reference_id'
    Rename-Constraint -Name 'FK_Source_Reference' -NewName 'FK_Reference_Source'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'RenameConstraint'

    Invoke-Rivet -Push 'RenameConstraint'

    Assert-ForeignKey -TableName 'Reference' -References 'Source'

}
