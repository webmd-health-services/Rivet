
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Remove-Row' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should remove specific rows' {
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
        $rows.count | Should -Be 5

        $rows.State.Contains("Texas") | Should -BeFalse
        $rows.State.Contains("California") | Should -BeTrue
        $rows.City.Contains("Houston") | Should -BeFalse
        $rows.City.Contains("San Antonio") | Should -BeFalse
        $rows.City.Contains("Los Angeles") | Should -BeTrue
        $rows.City.Contains("Phoenix") | Should -BeFalse

    }

    It 'should remove all rows' {
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

        $rows.count | Should -Be 0

    }

    It 'should remove all rows with truncate' {
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

        $rows.count | Should -Be 0

    }

}
