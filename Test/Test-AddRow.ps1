function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddRow' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldAddSingleRow
{
    @'
function Push-Migration
{
    Add-Table -Name 'Cities' -Column {
        VarChar 'City' -NotNull
        VarChar 'State' -NotNull
        Int 'Population' -NotNull
    } -Option 'data_compression = none'

    $RowToAdd = @( @{City = 'New York'; State = 'New York'; Population = 8336697})
    

    Add-Row -SchemaName 'dbo' -TableName 'Cities' -Column $RowToAdd
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'AddSingleRow'

    Invoke-Rivet -Push 'AddSingleRow'

    Assert-Table 'Cities'
    Assert-Column -TableName 'Cities' -Name 'City' -DataType 'VarChar' -NotNull
    Assert-Column -TableName 'Cities' -Name 'State' -DataType 'VarChar' -NotNull
    Assert-Column -TableName 'Cities' -Name 'Population' -DataType 'Int' -NotNull

    $rows = @(Get-Row -SchemaName 'dbo' -TableName 'Cities')

    Assert-Equal 1 $rows.count

    Assert-Equal "New York" $rows[0].City 
    Assert-Equal "New York" $rows[0].State 
    Assert-Equal "8336697" $rows[0].Population 
}


function Test-ShouldAddMultipleRows
{
    @'
function Push-Migration
{
    Add-Table -Name 'Cities' -Column {
        VarChar 'City' -NotNull
        VarChar 'State' -NotNull
        Int 'Population' -NotNull
    } -Option 'data_compression = none'

    $RowsToAdd = @( @{City = 'New York'; State = 'New York'; Population = 8336697}, @{City = 'Los Angeles'; State = 'California'; Population = 3857799} )

    Add-Row -SchemaName 'dbo' -TableName 'Cities' -Column $RowsToAdd
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'AddMultipleRow'

    Invoke-Rivet -Push 'AddMultipleRow'

    Assert-Table 'Cities'
    Assert-Column -TableName 'Cities' -Name 'City' -DataType 'VarChar' -NotNull
    Assert-Column -TableName 'Cities' -Name 'State' -DataType 'VarChar' -NotNull
    Assert-Column -TableName 'Cities' -Name 'Population' -DataType 'Int' -NotNull

    $rows = @(Get-Row -SchemaName 'dbo' -TableName 'Cities')

    Assert-Equal 2 $rows.count

    Assert-Equal "New York" $rows[0].City 
    Assert-Equal "Los Angeles" $rows[1].City 

    Assert-Equal "New York" $rows[0].State 
    Assert-Equal "California" $rows[1].State 

    Assert-Equal "8336697" $rows[0].Population 
    Assert-Equal "3857799" $rows[1].Population 
}