
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Update-Row' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should update specific rows' {
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
        Remove-Table 'City List'
    }

'@ | New-TestMigration -Name 'UpdateSpecificRows'

        Invoke-RTRivet -Push 'UpdateSpecificRows'

        Assert-Table 'City List'
        Assert-Column -TableName 'City List' -Name 'City Name' -DataType 'VarChar' -NotNull
        Assert-Column -TableName 'City List' -Name 'State' -DataType 'VarChar' -NotNull
        Assert-Column -TableName 'City List' -Name 'Population' -DataType 'Int' -NotNull

        $rows = @(Get-Row -SchemaName 'dbo' -TableName 'City List')
        $rows.count | Should -Be 8
        $rows.'City Name'.Contains("San Diego UPDATED") | Should -BeTrue
        $rows[7].Population | Should -Be 123456
    }

    It 'should update all rows' {
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
        Remove-Table 'Cities'
    }

'@ | New-TestMigration -Name 'UpdateAllRows'

        Invoke-RTRivet -Push 'UpdateAllRows'

        Assert-Table 'Cities'
        Assert-Column -TableName 'Cities' -Name 'City' -DataType 'VarChar' -NotNull
        Assert-Column -TableName 'Cities' -Name 'State' -DataType 'VarChar' -NotNull
        Assert-Column -TableName 'Cities' -Name 'Population' -DataType 'Int' -NotNull

        $rows = @(Get-Row -SchemaName 'dbo' -TableName 'Cities')
        $rows.count | Should -Be 8

        $rows.State.Contains("Oregon") | Should -BeTrue
        $rows.State.Contains("New York") | Should -BeFalse
        $rows.Population.Contains("8336697") | Should -BeFalse

    }

    It 'should update all types' {
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

    function Pop-Migration
    {
        Remove-Table 'Members'
    }
'@ | New-TestMigration -Name 'AddSingleRow'

        Invoke-RTRivet -Push 'AddSingleRow'

        Assert-Table 'Members'

        $rows = @(Get-Row -TableName 'Members')

        $rows.count | Should -Be 1

        $row = $rows[0]
        $row.MemberNumber | Should -Be 1
        $row.Name | Should -Be "Old McDonald's"
        $row.LastVisit | Should -Be ([DateTime]'10/18/2013 10:44:00')
        $row.LastStayDuration | Should -Be ([TimeSpan]'00:44:00')
        $row.IsActive | Should -BeTrue
        $row.Comments | Should -BeNullOrEmpty
    }

    It 'should allow sql expression for column value' {
        [datetime]$expectedUpdatedAt = Invoke-RivetTestQuery -Query 'select getutcdate()' -AsScalar
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
    function Pop-Migration
    {
        Remove-Table 'Members'
    }
'@ | New-TestMigration -Name 'AddSingleRow'

        Invoke-RTRivet -Push 'AddSingleRow'

        Assert-Table 'Members'

        $rows = @(Get-Row -TableName 'Members')

        $rows.count | Should -Be 1

        $row = $rows[0]
        $row.LastVisit | Should -Not -BeNullOrEmpty
        $updatedAt = $row.LastVisit
        ($expectedUpdatedAt -le $updatedAt) | Should -BeTrue
    }
}
