
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldRemoveSpecificRows
{
    @'
function Push-Migration
{
    Add-Table -Name 'Cities' -Column {
        VarChar 'City' -Max -NotNull
        VarChar 'State' -Max -NotNull
        Int 'Population' -NotNull
    } -Option 'data_compression = none'

    $Top8USCities = @(  
                        @{City = 'New York'; State = 'New York'; Population = 8336697}, 
                        @{City = 'Los Angeles'; State = 'California'; Population = 3857799},
                        @{City = 'Chicago'; State = 'Illnois'; Population = 2714856},
                        @{City = 'Houston'; State = 'Texas'; Population = 2160821},
                        @{City = 'Philadelphia'; State = 'Pennsylvania'; Population = 1547607},
                        @{City = 'Phoenix'; State = 'Arizona'; Population = 1488750},
                        @{City = 'San Antonio'; State = 'Texas'; Population = 1382951},
                        @{City = 'San Diego'; State = 'California'; Population = 1338348} 
                     )
    
    Add-Row -SchemaName 'dbo' -TableName 'Cities' -Column $Top8USCities

    #Should delete Houston, San Antonio and Phoenix
    Remove-Row -SchemaName 'dbo' -TableName 'Cities' -Where "State='Texas' or Population=1488750"

}

function Pop-Migration
{
    Remove-Table 'Cities'
}

'@ | New-TestMigration -Name 'RemoveSpecificRows'

    Invoke-RTRivet -Push 'RemoveSpecificRows'

    Assert-Table 'Cities'
    Assert-Column -TableName 'Cities' -Name 'City' -DataType 'VarChar' -NotNull
    Assert-Column -TableName 'Cities' -Name 'State' -DataType 'VarChar' -NotNull
    Assert-Column -TableName 'Cities' -Name 'Population' -DataType 'Int' -NotNull

    $rows = @(Get-Row -SchemaName 'dbo' -TableName 'Cities')
    Assert-Equal 5 $rows.count

    Assert-False $rows.State.Contains("Texas")
    Assert-True $rows.State.Contains("California")
    Assert-False $rows.City.Contains("Houston")
    Assert-False $rows.City.Contains("San Antonio")
    Assert-True $rows.City.Contains("Los Angeles")
    Assert-False $rows.City.Contains("Phoenix")

}

function Test-ShouldRemoveAllRows
{
    @'
function Push-Migration
{
    Add-Table -Name 'Cities' -Column {
        VarChar 'City' -Max -NotNull
        VarChar 'State' -Max -NotNull
        Int 'Population' -NotNull
    } -Option 'data_compression = none'

    $Top8USCities = @(  
                        @{City = 'New York'; State = 'New York'; Population = 8336697}, 
                        @{City = 'Los Angeles'; State = 'California'; Population = 3857799},
                        @{City = 'Chicago'; State = 'Illnois'; Population = 2714856},
                        @{City = 'Houston'; State = 'Texas'; Population = 2160821},
                        @{City = 'Philadelphia'; State = 'Pennsylvania'; Population = 1547607},
                        @{City = 'Phoenix'; State = 'Arizona'; Population = 1488750},
                        @{City = 'San Antonio'; State = 'Texas'; Population = 1382951},
                        @{City = 'San Diego'; State = 'California'; Population = 1338348} 
                     )
    
    Add-Row -SchemaName 'dbo' -TableName 'Cities' -Column $Top8USCities

    Remove-Row -SchemaName 'dbo' -TableName 'Cities' -All

}

function Pop-Migration
{
    Remove-Table 'Cities'
}

'@ | New-TestMigration -Name 'RemoveAllRows'

    Invoke-RTRivet -Push 'RemoveAllRows'

    Assert-Table 'Cities'
    Assert-Column -TableName 'Cities' -Name 'City' -DataType 'VarChar' -NotNull
    Assert-Column -TableName 'Cities' -Name 'State' -DataType 'VarChar' -NotNull
    Assert-Column -TableName 'Cities' -Name 'Population' -DataType 'Int' -NotNull

    $rows = @(Get-Row -SchemaName 'dbo' -TableName 'Cities')

    Assert-Equal 0 $rows.count

}

function Test-ShouldRemoveAllRowsWithTruncate
{
    @'
function Push-Migration
{
    Add-Table -Name 'Cities' -Column {
        VarChar 'City' -Max -NotNull
        VarChar 'State' -Max -NotNull
        Int 'Population' -NotNull
    } -Option 'data_compression = none'

    $Top8USCities = @(  
                        @{City = 'New York'; State = 'New York'; Population = 8336697}, 
                        @{City = 'Los Angeles'; State = 'California'; Population = 3857799},
                        @{City = 'Chicago'; State = 'Illnois'; Population = 2714856},
                        @{City = 'Houston'; State = 'Texas'; Population = 2160821},
                        @{City = 'Philadelphia'; State = 'Pennsylvania'; Population = 1547607},
                        @{City = 'Phoenix'; State = 'Arizona'; Population = 1488750},
                        @{City = 'San Antonio'; State = 'Texas'; Population = 1382951},
                        @{City = 'San Diego'; State = 'California'; Population = 1338348} 
                     )
    
    Add-Row -SchemaName 'dbo' -TableName 'Cities' -Column $Top8USCities

    Remove-Row -SchemaName 'dbo' -TableName 'Cities' -All -Truncate

}

function Pop-Migration
{
    Remove-Table 'Cities'
}

'@ | New-TestMigration -Name 'RemoveAllRowsWithTruncate'

    Invoke-RTRivet -Push 'RemoveAllRowsWithTruncate'

    Assert-Table 'Cities'
    Assert-Column -TableName 'Cities' -Name 'City' -DataType 'VarChar' -NotNull
    Assert-Column -TableName 'Cities' -Name 'State' -DataType 'VarChar' -NotNull
    Assert-Column -TableName 'Cities' -Name 'Population' -DataType 'Int' -NotNull

    $rows = @(Get-Row -SchemaName 'dbo' -TableName 'Cities')

    Assert-Equal 0 $rows.count

}

