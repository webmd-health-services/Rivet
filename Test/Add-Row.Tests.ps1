
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-Row' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should add single row' {
        # Yes.  Spaces in names so we check that the names get quoted.
        @'
    function Push-Migration
    {
        Add-Table 'Table of Cities' {
            VarChar 'City Name' -Max -NotNull
            VarChar 'State Name' -Max -NotNull
            Int 'Population' -NotNull
            datetime2 'Founded On' -NotNull
            time 'Utc Offset' -NotNull
            varchar 'Description' 100
            bit 'Still Present'
        }

        Add-Row 'Table of Cities' @( @{
            'City Name' = 'New York';
            'State Name' = 'New York';
            'Population' = 8336697;
            'Founded On' = ([DateTime]'1/1/1624');
            'Utc Offset' = ([TimeSpan]'05:00:00');
            'Description' = "New York's the greatest city in the world!";
            'Still Present' = $true;
        })
    }

    function Pop-Migration
    {
        Remove-Table 'Table of Cities'
    }

'@ | New-TestMigration -Name 'AddSingleRow'

        Invoke-RTRivet -Push 'AddSingleRow'

        Assert-Table 'Table of Cities'

        $rows = @(Get-Row -SchemaName 'dbo' -TableName 'Table of Cities')

        $rows.count | Should -Be 1

        $row = $rows[0]
        $rows.'City Name' | Should -Be "New York"
        $rows.'State Name' | Should -Be "New York"
        $rows.Population | Should -Be "8336697"
        $row.'Founded On' | Should -Be ([DateTime]'1/1/1624')
        $row.'Utc Offset' | Should -Be ([TimeSpan]'05:00:00')
        $row.Description | Should -Be "New York's the greatest city in the world!"
        $row.'Still Present' | Should -BeTrue
    }


    It 'should add multiple rows' {
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
        Remove-Table 'Cities'
    }

'@ | New-TestMigration -Name 'AddMultipleRow'

        Invoke-RTRivet -Push 'AddMultipleRow'

        Assert-Table 'Cities'
        Assert-Column -TableName 'Cities' -Name 'City' -DataType 'VarChar' -NotNull
        Assert-Column -TableName 'Cities' -Name 'State' -DataType 'VarChar' -NotNull
        Assert-Column -TableName 'Cities' -Name 'Population' -DataType 'Int' -NotNull

        $rows = @(Get-Row -SchemaName 'dbo' -TableName 'Cities')

        $rows.count | Should -Be 2

        $rows[0].City | Should -Be "New York"
        $rows[1].City | Should -Be "Los Angeles"

        $rows[0].State | Should -Be "New York"
        $rows[1].State | Should -Be "California"

        $rows[0].Population | Should -Be "8336697"
        $rows[1].Population | Should -Be "3857799"
    }

    It 'should add multiple rows by pipe' {
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
        Remove-Table 'Cities'
    }

'@ | New-TestMigration -Name 'AddMultipleRowByPipe'

        Invoke-RTRivet -Push 'AddMultipleRowByPipe'

        Assert-Table 'Cities'
        Assert-Column -TableName 'Cities' -Name 'City' -DataType 'VarChar' -NotNull
        Assert-Column -TableName 'Cities' -Name 'State' -DataType 'VarChar' -NotNull
        Assert-Column -TableName 'Cities' -Name 'Population' -DataType 'Int' -NotNull

        $rows = @(Get-Row -SchemaName 'dbo' -TableName 'Cities')

        $rows.count | Should -Be 2

        $rows[0].City | Should -Be "New York"
        $rows[1].City | Should -Be "Los Angeles"

        $rows[0].State | Should -Be "New York"
        $rows[1].State | Should -Be "California"

        $rows[0].Population | Should -Be "8336697"
        $rows[1].Population | Should -Be "3857799"
    }

    It 'should add row with null value' {
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
        Remove-Table 'Cities'
    }

'@ | New-TestMigration -Name 'AddSingleRow'

        Invoke-RTRivet -Push 'AddSingleRow'

        Assert-Table 'Cities'

        $rows = @(Get-Row -TableName 'Cities')

        $rows.count | Should -Be 1

        $row = $rows[0]
        $row.Name | Should -BeNullOrEmpty
    }

    It 'should allow inserting identities' {
       @'
    function Push-Migration
    {
        Add-Table 'Cities' {
            int 'ID' -Identity
            varchar 'Name' 100
        }

        Add-Row 'Cities' -IdentityInsert @( @{ ID = 200; Name = $null } )
    }

    function Pop-Migration
    {
        Remove-Table 'Cities'
    }
'@ | New-TestMigration -Name 'AddSingleRow'

        Invoke-RTRivet -Push 'AddSingleRow'

        Assert-Table 'Cities'

        $rows = @(Get-Row -TableName 'Cities')

        $rows.count | Should -Be 1

        $row = $rows[0]
        $row.Name | Should -BeNullOrEmpty
        $row.ID | Should -Be 200

    }
}
