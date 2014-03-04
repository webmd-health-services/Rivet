function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'RivetTest' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldUpdateSpecificRows
{
    # Yes.  Spaces in names so we check that the names get quoted.
    @'
function Push-Migration
{
    Add-Table -Name 'City List' -Column {
        VarChar 'City Name' -Max -NotNull
        VarChar 'State' -Max -NotNull
        Int 'Population' -NotNull
    } -Option 'data_compression = none'

    $Top8USCities = @(  
                        @{'City Name' = 'New York'; State = 'New York'; Population = 8336697}, 
                        @{'City Name' = 'Los Angeles'; State = 'California'; Population = 3857799},
                        @{'City Name' = 'Chicago'; State = 'Illnois'; Population = 2714856},
                        @{'City Name' = 'Houston'; State = 'Texas'; Population = 2160821},
                        @{'City Name' = 'Philadelphia'; State = 'Pennsylvania'; Population = 1547607},
                        @{'City Name' = 'Phoenix'; State = 'Arizona'; Population = 1488750},
                        @{'City Name' = 'San Antonio'; State = 'Texas'; Population = 1382951},
                        @{'City Name' = 'San Diego'; State = 'California'; Population = 1338348} 
                     )

    $Changes = @{ 
                    "City Name" = "San Diego UPDATED";
                    "Population" = 123456
                }     
    
    Add-Row -SchemaName 'dbo' -TableName 'City List' -Column $Top8USCities
    Update-Row -SchemaName 'dbo' -TableName 'City List' -Column $Changes -Where "[City Name] = 'San Diego'"
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'UpdateSpecificRows'

    Invoke-Rivet -Push 'UpdateSpecificRows'

    Assert-Table 'City List'
    Assert-Column -TableName 'City List' -Name 'City Name' -DataType 'VarChar' -NotNull
    Assert-Column -TableName 'City List' -Name 'State' -DataType 'VarChar' -NotNull
    Assert-Column -TableName 'City List' -Name 'Population' -DataType 'Int' -NotNull

    $rows = @(Get-Row -SchemaName 'dbo' -TableName 'City List')
    Assert-Equal 8 $rows.count
    Assert-True $rows.'City Name'.Contains("San Diego UPDATED")
    Assert-Equal 123456 $rows[7].Population
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
    Assert-Null $row.Comments
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
    Assert-True ($row.LastVisit.AddSeconds(-5) -le (Get-Date).ToUniversalTime())
}
