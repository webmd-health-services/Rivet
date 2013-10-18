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

function Test-ShouldUpdateSpecificRows
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

    $Changes = @{ 
                    "State" = "Oregon";
                    "Population" = 123456
                }     
    
    Add-Row -SchemaName 'dbo' -TableName 'Cities' -Column $Top8USCities
    Update-Row -SchemaName 'dbo' -TableName 'Cities' -Column $Changes -Where "City = 'San Diego'"
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'UpdateSpecificRows'

    Invoke-Rivet -Push 'UpdateSpecificRows'

    Assert-Table 'Cities'
    Assert-Column -TableName 'Cities' -Name 'City' -DataType 'VarChar' -NotNull
    Assert-Column -TableName 'Cities' -Name 'State' -DataType 'VarChar' -NotNull
    Assert-Column -TableName 'Cities' -Name 'Population' -DataType 'Int' -NotNull

    $rows = @(Get-Row -SchemaName 'dbo' -TableName 'Cities')
    Assert-Equal 8 $rows.count
    Assert-True $rows.City.Contains("San Diego")
    Assert-True $rows.State.Contains("Oregon")
    Assert-Equal "Oregon" $rows[7].State
}

function Test-ShouldUpdateAllRows
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

    $Changes = @{ 
                    "State" = "Oregon";
                    "Population" = 123456
                }     
    
    Add-Row -SchemaName 'dbo' -TableName 'Cities' -Column $Top8USCities
    Update-Row -TableName 'Cities' -Column $Changes -All
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'UpdateAllRows'

    Invoke-Rivet -Push 'UpdateAllRows'

    Assert-Table 'Cities'
    Assert-Column -TableName 'Cities' -Name 'City' -DataType 'VarChar' -NotNull
    Assert-Column -TableName 'Cities' -Name 'State' -DataType 'VarChar' -NotNull
    Assert-Column -TableName 'Cities' -Name 'Population' -DataType 'Int' -NotNull

    $rows = @(Get-Row -SchemaName 'dbo' -TableName 'Cities')
    Assert-Equal 8 $rows.count

    Assert-True $rows.State.Contains("Oregon")
    Assert-False $rows.State.Contains("New York")
    Assert-False $rows.Population.Contains("8336697")

}

function Test-ShouldUpdateAllTypes
{
    @'
function Push-Migration
{
    Add-Table 'Members' {
        int 'ID' -Identity
        int 'MemberNumber' 
        varchar 'Name' 50
        datetime 'LastVisit'
        time 'LastStayDuration'
        bit 'IsActive'
        varchar 'Comments' 100
    }

    Add-Row 'Members' @( @{
        MemberNumber = $null;
        Name = $null;
        LastVisit = $null;
        LastStayDuration = $null;
        IsActive = $null;
        Comments = "I know.  It's a pretty funny record.  So goes the world of testing!"
    })

    Update-Row 'Members' -Where 'ID = 1' @{
        MemberNumber = 1;
        Name = "Old McDonald's";
        LastVisit = ([DateTime]'10/18/2013 10:44:00');
        LastStayDuration = ([TimeSpan]'00:44:00');
        IsActive = $true;
        Comments = $null;
    }
}
'@ | New-Migration -Name 'AddSingleRow'

    Invoke-Rivet -Push 'AddSingleRow'

    Assert-Table 'Members'

    $rows = @(Get-Row -TableName 'Members')

    Assert-Equal 1 $rows.count

    $row = $rows[0]
    Assert-Equal 1 $row.MemberNumber
    Assert-Equal "Old McDonald's" $row.Name
    Assert-Equal ([DateTime]'10/18/2013 10:44:00') $row.LastVisit
    Assert-Equal ([TimeSpan]'00:44:00') $row.LastStayDuration
    Assert-Equal $true $row.IsActive
    Assert-Null $row.Description
}

function Test-ShouldAllowSqlExpressionForColumnValue
{
    @'
function Push-Migration
{
    Add-Table 'Members' {
        int 'ID' -Identity
        datetime 'LastVisit'
    }

    Add-Row 'Members' @( @{
        LastVisit = $null;
    })

    Update-Row 'Members' -Where 'ID = 1' -RawColumnValue @{
        LastVisit = 'getutcdate()';
    }
}
'@ | New-Migration -Name 'AddSingleRow'

    Invoke-Rivet -Push 'AddSingleRow'

    Assert-Table 'Members'

    $rows = @(Get-Row -TableName 'Members')

    Assert-Equal 1 $rows.count

    $row = $rows[0]
    Assert-NotNull $row.LastVisit
    Assert-True ($row.LastVisit.AddSeconds(-1) -le (Get-Date).ToUniversalTime())
}
