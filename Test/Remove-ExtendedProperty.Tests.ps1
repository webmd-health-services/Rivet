
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Setup
{
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
}

function Test-ShouldRemoveExtendedPropertyToSchema
{
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

    $expinfo = Get-ExtendedProperties

    Assert-Null $expinfo

}

function Test-ShouldRemoveExtendedPropertyToTable
{
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

    $expinfo = Get-ExtendedProperties

    Assert-Null $expinfo

}

function Test-ShouldRemoveExtendedPropertyToView
{
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

    $expinfo = Get-ExtendedProperties

    Assert-Null $expinfo

}

function Test-ShouldRemoveExtendedPropertyToViewInCustomSchema
{
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

    $expinfo = Get-ExtendedProperties

    Assert-Null $expinfo

}

function Test-ShouldRemoveExtendedPropertyToTableColumn
{
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

    $expinfo = Get-ExtendedProperties

    Assert-Null $expinfo

}

function Test-ShouldRemoveExtendedPropertyToViewColumn
{
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

    $expinfo = Get-ExtendedProperties

    Assert-Null $expinfo

}
