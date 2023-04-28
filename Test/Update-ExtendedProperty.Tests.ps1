
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Update-ExtendedProperty' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should update extended property to schema' {
        @'
    function Push-Migration
    {
        Add-Schema 'fizz'
        Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -SchemaName 'fizz'
        Update-ExtendedProperty -Name 'Deploy' -Value 'FALSE' -SchemaName 'fizz'
    }

    function Pop-Migration
    {
        Remove-Schema 'fizz'
    }

'@ | New-TestMigration -Name 'UpdateExtendedPropertyToSchema'

        Invoke-RTRivet -Push 'UpdateExtendedPropertyToSchema'

        $expinfo = Get-MSSqlExtendedProperty -Session $RTSession -SchemaName 'fizz'

        $expinfo[0].name | Should -Be 'Deploy'
        $expinfo[0].value | Should -Be 'FALSE'
        $expinfo[0].objtype | Should -Be 'SCHEMA'
    }

    It 'should update extended property to table' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            Int ID
        }

        Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -TableName 'Foobar'
        Update-ExtendedProperty -Name 'Deploy' -Value 'FALSE' -TableName 'Foobar'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'UpdateExtendedPropertyToTable'

        Invoke-RTRivet -Push 'UpdateExtendedPropertyToTable'

        $expinfo = Get-MSSqlExtendedProperty -Session $RTSession -TableName 'Foobar'

        $expinfo[0].name | Should -Be 'Deploy'
        $expinfo[0].value | Should -Be 'FALSE'
        $expinfo[0].objtype | Should -Be 'TABLE'

    }


    It 'should update extended property to view' {
        @'
    function Push-Migration
    {
        Add-View -SchemaName 'dbo' 'Foobar' 'AS select * from rivet.Migrations'

        Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -ViewName 'Foobar'

        Update-ExtendedProperty -Name 'Deploy' -Value 'FALSE' -ViewName 'Foobar'
    }

    function Pop-Migration
    {
        Remove-View 'Foobar'
    }

'@ | New-TestMigration -Name 'UpdateExtendedPropertyToView'

        Invoke-RTRivet -Push 'UpdateExtendedPropertyToView'

        $expinfo = Get-MSSqlExtendedProperty -Session $RTSession -ViewName 'Foobar'

        $expinfo[0].name | Should -Be 'Deploy'
        $expinfo[0].value | Should -Be 'FALSE'
        $expinfo[0].objtype | Should -Be 'VIEW'

    }


    It 'should update extended property to view in custom schema' {
        @'
    function Push-Migration
    {
        Add-Schema 'metric'
        Add-View -SchemaName 'metric' 'Foobar' 'AS select * from rivet.Migrations'
        Add-ExtendedProperty 'Deploy' 'TRUE' -SchemaName 'metric' -ViewName 'Foobar'
        Update-ExtendedProperty 'Deploy' 'FALSE' -SchemaName 'metric' -ViewName 'Foobar'
    }

    function Pop-Migration
    {
        Remove-View 'Foobar' -schemaname 'metric'
        Remove-Schema 'metric'
    }

'@ | New-TestMigration -Name 'UpdateExtendedPropertyToView'

        Invoke-RTRivet -Push 'UpdateExtendedPropertyToView'

        $expinfo = Get-MSSqlExtendedProperty -Session $RTSession -SchemaName 'metric' -ViewName 'Foobar'

        $expinfo[0].name | Should -Be 'Deploy'
        $expinfo[0].value | Should -Be 'FALSE'
        $expinfo[0].objtype | Should -Be 'VIEW'

    }


    It 'should update extended property to table column' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            Int ID
        }

        Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -TableName 'Foobar' -ColumnName 'ID'
        Update-ExtendedProperty -Name 'Deploy' -Value 'FALSE' -TableName 'Foobar' -ColumnName 'ID'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'UpdateExtendedPropertyToTableColumn'

        Invoke-RTRivet -Push 'UpdateExtendedPropertyToTableColumn'

        $expinfo = Get-MSSqlExtendedProperty -Session $RTSession -TableName 'Foobar' -ColumnName 'ID'

        $expinfo[0].name | Should -Be 'Deploy'
        $expinfo[0].value | Should -Be 'FALSE'
        $expinfo[0].objtype | Should -Be 'COLUMN'

    }


    It 'should update extended property to view column' {
        @'
    function Push-Migration
    {
        Add-Table Table {
            Int ID
        }

        Add-View -SchemaName 'dbo' 'Foobar' 'AS select * from rivet.Migrations'

        Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -ViewName 'Foobar' -ColumnName 'ID'
        Update-ExtendedProperty -Name 'Deploy' -Value 'FALSE' -ViewName 'Foobar' -ColumnName 'ID'
    }

    function Pop-Migration
    {
        Remove-View 'Foobar'
        Remove-Table 'Table'
    }

'@ | New-TestMigration -Name 'UpdateExtendedPropertyToViewColumn'

        Invoke-RTRivet -Push 'UpdateExtendedPropertyToViewColumn'

        $expinfo = Get-MSSqlExtendedProperty -Session $RTSession -ViewName 'Foobar' -ColumnName 'ID'

        $expinfo[0].name | Should -Be 'Deploy'
        $expinfo[0].value | Should -Be 'FALSE'
        $expinfo[0].objtype | Should -Be 'COLUMN'

    }



    It 'should allow null property value' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            Int ID
        }

        Add-ExtendedProperty 'Deploy' 'Goodbye!' -TableName 'Foobar'
        Update-ExtendedProperty 'Deploy' $null -TableName 'Foobar'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'AllowNullPropertyValue'

        Invoke-RTRivet -Push 'AllowNullPropertyValue'

        $expinfo = Get-MSSqlExtendedProperty -Session $RTSession -TableName 'Foobar'

        $expInfo[0].value | Should -BeNullOrEmpty
    }


    It 'should allow empty property value' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            Int ID
        }

        Add-ExtendedProperty 'Deploy' 'Goodbye!' -TableName 'Foobar'
        Update-ExtendedProperty 'Deploy' '' -TableName 'Foobar'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'AllowEmptyPropertyValue'

        Invoke-RTRivet -Push 'AllowEmptyPropertyValue'

        $expinfo = Get-MSSqlExtendedProperty -Session $RTSession -TableName 'Foobar'

        $expInfo[0].value | Should -Be ''

    }
}
