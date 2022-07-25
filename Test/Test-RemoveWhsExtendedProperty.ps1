
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Setup
{
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
}

function Test-ShouldRemoveWhsExtendedPropertyToSchema
{
    @'
function Push-Migration
{
    Add-Schema 'fizz'
    Add-WhsExtendedProperty -SchemaName 'fizz' -ContentType 'PII' -Encrypted $True -RelatesTo 'Stuff'
    Remove-WhsExtendedProperty -SchemaName 'fizz' -Name 'WHS_ContentType'
    Remove-WhsExtendedProperty -SchemaName 'fizz' -Name 'WHS_Encrypted'
    Remove-WhsExtendedProperty -SchemaName 'fizz' -Name 'WHS_RelatesTo'
}

function Pop-Migration
{
    Remove-Schema 'fizz'
}

'@ | New-TestMigration -Name 'RemoveWhsExtendedPropertyToSchema'

    Invoke-RTRivet -Push 'RemoveWhsExtendedPropertyToSchema'

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

    Add-WhsExtendedProperty -TableName 'Foobar' -ContentType 'PHI' -Encrypted $False -RelatesTo 'Stuff'
    Remove-WhsExtendedProperty -TableName 'Foobar' -Name 'WHS_ContentType'
    Remove-WhsExtendedProperty -TableName 'Foobar' -Name 'WHS_Encrypted'
    Remove-WhsExtendedProperty -TableName 'Foobar' -Name 'WHS_RelatesTo'
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'RemoveWhsExtendedPropertyToTable'

    Invoke-RTRivet -Push 'RemoveWhsExtendedPropertyToTable'

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

    Add-WhsExtendedProperty -TableName 'Foobar' -ColumnName 'ID' -ContentType 'PHIandPII' -Encrypted $True -RelatesTo 'Stuff'
    Remove-WhsExtendedProperty -TableName 'Foobar' -ColumnName 'ID' -Name 'WHS_ContentType'
    Remove-WhsExtendedProperty -TableName 'Foobar' -ColumnName 'ID' -Name 'WHS_Encrypted'
    Remove-WhsExtendedProperty -TableName 'Foobar' -ColumnName 'ID' -Name 'WHS_RelatesTo'
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'RemoveWhsExtendedPropertyToTableColumn'

    Invoke-RTRivet -Push 'RemoveWhsExtendedPropertyToTableColumn'

    $expinfo = Get-ExtendedProperties

    Assert-Null $expinfo
}
