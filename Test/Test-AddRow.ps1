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

function Test-ShouldAddSingleRow
{
    @'
function Push-Migration
{
    Add-Table 'Cities' {
        VarChar 'City' -Max -NotNull
        VarChar 'State' -Max -NotNull
        Int 'Population' -NotNull
        datetime2 'FoundedOn' -NotNull
        time 'UtcOffset' -NotNull
        varchar 'Description' 100
        bit 'StillPresent' 
    }

    Add-Row 'Cities' @( @{
        City = 'New York'; 
        State = 'New York'; 
        Population = 8336697;
        FoundedOn = ([DateTime]'1/1/1624');
        UtcOffset = ([TimeSpan]'05:00:00');
        Description = "New York's the greatest city in the world!";
        StillPresent = $true;
    })
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'AddSingleRow'

    Invoke-Rivet -Push 'AddSingleRow'

    Assert-Table 'Cities'

    $rows = @(Get-Row -SchemaName 'dbo' -TableName 'Cities')

    Assert-Equal 1 $rows.count

    $row = $rows[0]
    Assert-Equal "New York" $rows.City 
    Assert-Equal "New York" $rows.State 
    Assert-Equal "8336697" $rows.Population 
    Assert-Equal ([DateTime]'1/1/1624') $row.FoundedOn
    Assert-Equal ([TimeSpan]'05:00:00') $row.UtcOffset
    Assert-Equal "New York's the greatest city in the world!" $row.Description
    Assert-Equal $True $row.StillPresent
}


function Test-ShouldAddMultipleRows
{
    @'
function Push-Migration
{
    Add-Table -Name 'Cities' -Column {
        VarChar 'City' -Max -NotNull
        VarChar 'State' -Max -NotNull
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

function Test-ShouldAddMultipleRowsByPipe
{
    @'
function Push-Migration
{
    Add-Table -Name 'Cities' -Column {
        VarChar 'City' -Max -NotNull
        VarChar 'State' -Max -NotNull
        Int 'Population' -NotNull
    } -Option 'data_compression = none'

    @( @{City = 'New York'; State = 'New York'; Population = 8336697}, @{City = 'Los Angeles'; State = 'California'; Population = 3857799} ) | Add-Row -SchemaName 'dbo' -TableName 'Cities'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'AddMultipleRowByPipe'

    Invoke-Rivet -Push 'AddMultipleRowByPipe'

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

function Test-ShouldAddRowWithNullValue
{
   @'
function Push-Migration
{
    Add-Table 'Cities' {
        VarChar 'Name' 10
    }

    Add-Row 'Cities' @( @{ Name = $null } )
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'AddSingleRow'

    Invoke-Rivet -Push 'AddSingleRow'

    Assert-Table 'Cities'

    $rows = @(Get-Row -TableName 'Cities')

    Assert-Equal 1 $rows.count

    $row = $rows[0]
    Assert-Null $row.Name
}

function Test-ShouldAllowInsertingIdentities
{
   @'
function Push-Migration
{
    Add-Table 'Cities' {
        int 'ID' -Identity
        varchar 'Name' 100
    }

    Add-Row 'Cities' -IdentityInsert @( @{ ID = 200; Name = $null } )
}
'@ | New-Migration -Name 'AddSingleRow'

    Invoke-Rivet -Push 'AddSingleRow'

    Assert-Table 'Cities'

    $rows = @(Get-Row -TableName 'Cities')

    Assert-Equal 1 $rows.count

    $row = $rows[0]
    Assert-Null $row.Name
    Assert-Equal 200 $row.ID
    
}