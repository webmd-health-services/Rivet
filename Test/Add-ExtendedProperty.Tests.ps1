
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-ExtendedProperty' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should add extended property to schema' {
        @'
    function Push-Migration
    {
        Add-Schema 'fizz'
        Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -SchemaName 'fizz'
    }

    function Pop-Migration
    {
        Remove-Schema 'fizz'
    }

'@ | New-TestMigration -Name 'AddExtendedPropertyToSchema'

        Invoke-RTRivet -Push 'AddExtendedPropertyToSchema'

        $expinfo = Get-ExtendedProperties

        'Deploy' | Should -Be $expinfo[0].name
        'TRUE' | Should -Be $expinfo[0].value
        'SCHEMA' | Should -Be $expinfo[0].class_desc

    }

    It 'should add extended property to table' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            Int ID
        }

        Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -TableName 'Foobar'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'AddExtendedPropertyToTable'

        Invoke-RTRivet -Push 'AddExtendedPropertyToTable'

        $expinfo = Get-ExtendedProperties

        $expinfo[0].name | Should -Be 'Deploy'
        $expinfo[0].value | Should -Be 'TRUE'
        $expinfo[0].class_desc | Should -Be 'OBJECT_OR_COLUMN'

    }

    It 'should add extended property to view' {
        @'
    function Push-Migration
    {
        Add-View -SchemaName 'dbo' 'Foobar' 'AS select * from rivet.Migrations'

        Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -ViewName 'Foobar'
    }

    function Pop-Migration
    {
        Remove-View 'Foobar'
    }

'@ | New-TestMigration -Name 'AddExtendedPropertyToView'

        Invoke-RTRivet -Push 'AddExtendedPropertyToView'

        $expinfo = Get-ExtendedProperties

        $expinfo[0].name | Should -Be 'Deploy'
        $expinfo[0].value | Should -Be 'TRUE'
        $expinfo[0].class_desc | Should -Be 'OBJECT_OR_COLUMN'

    }


    It 'should add extended property to view in custom schema' {
        @'
    function Push-Migration
    {
        Add-Schema 'metric'
        Add-View -SchemaName 'metric' 'Foobar' 'AS select * from rivet.Migrations'

        Add-ExtendedProperty 'Deploy' 'TRUE' -SchemaName 'metric' -ViewName 'Foobar'
    }

    function Pop-Migration
    {
        Remove-View 'Foobar' -SchemaName 'metric'
        Remove-Schema 'metric'
    }

'@ | New-TestMigration -Name 'AddExtendedPropertyToView'

        Invoke-RTRivet -Push 'AddExtendedPropertyToView'

        $expinfo = Get-ExtendedProperties

        $expinfo[0].name | Should -Be 'Deploy'
        $expinfo[0].value | Should -Be 'TRUE'
        $expinfo[0].class_desc | Should -Be 'OBJECT_OR_COLUMN'

    }

    It 'should add extended property to table column' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            Int ID
        }

        Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -TableName 'Foobar' -ColumnName 'ID'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'AddExtendedPropertyToTableColumn'

        Invoke-RTRivet -Push 'AddExtendedPropertyToTableColumn'

        $expinfo = Get-ExtendedProperties

        $expinfo[0].name | Should -Be 'Deploy'
        $expinfo[0].value | Should -Be 'TRUE'
        $expinfo[0].class_desc | Should -Be 'OBJECT_OR_COLUMN'

    }

    It 'should add extended property to view column' {
        @'
    function Push-Migration
    {
        Add-Table Table {
            Int ID
        }

        Add-View -SchemaName 'dbo' 'Foobar' 'AS select * from rivet.Migrations'

        Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -ViewName 'Foobar' -ColumnName 'ID'
    }

    function Pop-Migration
    {
        Remove-View 'Foobar'
        Remove-Table 'Table'
    }

'@ | New-TestMigration -Name 'AddExtendedPropertyToViewColumn'

        Invoke-RTRivet -Push 'AddExtendedPropertyToViewColumn'

        $expinfo = Get-ExtendedProperties

        $expinfo[0].name | Should -Be 'Deploy'
        $expinfo[0].value | Should -Be 'TRUE'
        $expinfo[0].class_desc | Should -Be 'OBJECT_OR_COLUMN'

    }

    It 'should allow null property value' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            Int ID
        }

        Add-ExtendedProperty 'Deploy' $null -TableName 'Foobar' -ColumnName 'ID'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'AllowNullPropertyValue'

        Invoke-RTRivet -Push 'AllowNullPropertyValue'

        $expinfo = Get-ExtendedProperties

        $expInfo[0].value | Should -BeNullOrEmpty
    }


    It 'should allow empty property value' {
        @'
    function Push-Migration
    {
        Add-Table Foobar {
            Int ID
        }

        Add-ExtendedProperty 'Deploy' '' -TableName 'Foobar' -ColumnName 'ID'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'AddExtendedPropertyToColumn'

        Invoke-RTRivet -Push 'AddExtendedPropertyToColumn'

        $expinfo = Get-ExtendedProperties

        $expInfo[0].value | Should -Be ''

    }
}
