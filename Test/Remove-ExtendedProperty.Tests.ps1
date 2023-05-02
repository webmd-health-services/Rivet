
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Remove-ExtendedProperty' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should remove extended property to schema' {
        @'
function Push-Migration
{
    Add-Schema 'fizz'
    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -SchemaName 'fizz'
    Remove-ExtendedProperty -Name 'Deploy' -SchemaName 'fizz'
}

function Pop-Migration
{
    Remove-Schema 'fizz'
}

'@ | New-TestMigration -Name 'RemoveExtendedPropertyToSchema'

        Invoke-RTRivet -Push 'RemoveExtendedPropertyToSchema'

        Test-ExtendedProperty -SchemaName 'fizz' | Should -BeFalse
    }

    It 'should remove extended property to table' {
        @'
function Push-Migration
{
    Add-Table Foobar {
        Int ID
    }

    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -TableName 'Foobar'
    Remove-ExtendedProperty -Name 'Deploy' -TableName 'Foobar'
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'RemoveExtendedPropertyToTable'

        Invoke-RTRivet -Push 'RemoveExtendedPropertyToTable'

        Test-ExtendedProperty -TableName 'Deploy' | Should -BeFalse
    }

    It 'should remove extended property to view' {
        @'
function Push-Migration
{
    Add-View -SchemaName 'dbo' 'Foobar' 'AS select * from rivet.Migrations'
    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -ViewName 'Foobar'
    Remove-ExtendedProperty -Name 'Deploy' -ViewName 'Foobar'
}

function Pop-Migration
{
    Remove-View 'Foobar'
}

'@ | New-TestMigration -Name 'RemoveExtendedPropertyToView'

        Invoke-RTRivet -Push 'RemoveExtendedPropertyToView'

        Test-ExtendedProperty -ViewName 'Foobar' | Should -BeFalse
    }

    It 'should remove extended property to view in custom schema' {
        @'
function Push-Migration
{
    Add-Schema 'metric'
    Add-View -SchemaName 'metric' 'Foobar' 'AS select * from rivet.Migrations'
    Add-ExtendedProperty 'Deploy' 'TRUE' -SchemaName 'metric' -ViewName 'Foobar'
    Remove-ExtendedProperty 'Deploy' -SchemaName 'metric' -ViewName 'Foobar'
}

function Pop-Migration
{
    Remove-View 'Foobar' -schemaname 'metric'
    Remove-Schema 'metric'
}

'@ | New-TestMigration -Name 'RemoveExtendedPropertyToView'

        Invoke-RTRivet -Push 'RemoveExtendedPropertyToView'

        Test-ExtendedProperty -SchemaName 'metric' -ViewName 'Foobar' | Should -BeFalse
    }

    It 'should remove extended property to table column' {
        @'
function Push-Migration
{
    Add-Table Foobar {
        Int ID
    }

    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -TableName 'Foobar' -ColumnName 'ID'
    Remove-ExtendedProperty -Name 'Deploy' -TableName 'Foobar' -ColumnName 'ID'
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'RemoveExtendedPropertyToTableColumn'

        Invoke-RTRivet -Push 'RemoveExtendedPropertyToTableColumn'

        Test-ExtendedProperty -TableName 'Foobar' -ColumnName 'ID' | Should -BeFalse
    }

    It 'should remove extended property to view column' {
        @'
function Push-Migration
{
    Add-Table Foobar2 {
        Int ID
    }
    Add-View -SchemaName 'dbo' 'Foobar' 'AS select * from rivet.Migrations'
    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -ViewName 'Foobar' -ColumnName 'ID'
    Remove-ExtendedProperty -Name 'Deploy' -ViewName 'Foobar' -ColumnName 'ID'
}

function Pop-Migration
{
    Remove-View 'Foobar'
    Remove-Table 'Foobar2'
}

'@ | New-TestMigration -Name 'RemoveExtendedPropertyToViewColumn'

        Invoke-RTRivet -Push 'RemoveExtendedPropertyToViewColumn'

        Test-ExtendedProperty -ViewName 'Foobar' -ColumnName 'ID' | Should -BeFalse
    }
}
