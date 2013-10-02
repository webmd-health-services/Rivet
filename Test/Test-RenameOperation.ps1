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
        VarChar 'varchar' -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
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
