
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldAddWhsExtendedPropertyToSchema
{
    @'
function Push-Migration
{
    Add-Schema 'fizz'
    Add-WhsExtendedProperty  -SchemaName 'fizz' -ContentType 'PII' -Encrypted $True -RelatesTo @('Stuff')
}

function Pop-Migration
{
    Remove-Schema 'fizz'
}

'@ | New-TestMigration -Name 'AddWhsExtendedPropertyToSchema'

    Invoke-RTRivet -Push 'AddWhsExtendedPropertyToSchema'

    $expinfo = Get-ExtendedProperties | Sort-Object -Property name

    Assert-Equal $expinfo[0].name 'WHS_ContentType'
    Assert-Equal $expinfo[0].value 'PII'
    Assert-Equal $expinfo[0].class_desc 'SCHEMA'

    Assert-Equal $expinfo[1].name 'WHS_Encrypted'
    Assert-Equal $expinfo[1].value $True
    Assert-Equal $expinfo[1].class_desc 'SCHEMA'

    Assert-Equal $expinfo[2].name 'WHS_RelatesTo'
    Assert-Equal $expinfo[2].value 'Stuff'
    Assert-Equal $expinfo[2].class_desc 'SCHEMA'
}

function Test-ShouldAddWhsExtendedPropertyToTable
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Int ID
    }

    Add-WhsExtendedProperty -TableName 'Foobar' -ContentType 'PHI' -Encrypted $False -RelatesTo @('Stuff', 'MoreStuff')
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'AddWhsExtendedPropertyToTable'

    Invoke-RTRivet -Push 'AddWhsExtendedPropertyToTable'

    $expinfo = Get-ExtendedProperties | Sort-Object -Property name

    Assert-Equal $expinfo[0].name 'WHS_ContentType'
    Assert-Equal $expinfo[0].value 'PHI'
    Assert-Equal $expinfo[0].class_desc 'OBJECT_OR_COLUMN'

    Assert-Equal $expinfo[1].name 'WHS_Encrypted'
    Assert-Equal $expinfo[1].value $False
    Assert-Equal $expinfo[1].class_desc 'OBJECT_OR_COLUMN'

    Assert-Equal $expinfo[2].name 'WHS_RelatesTo'
    Assert-Equal $expinfo[2].value 'Stuff, MoreStuff'
    Assert-Equal $expinfo[2].class_desc 'OBJECT_OR_COLUMN'
}

function Test-ShouldAddWhsExtendedPropertyToTableColumn
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Int ID
    }

    Add-WhsExtendedProperty -TableName 'Foobar' -ColumnName 'ID' -ContentType 'PHIAndPII' -Encrypted $True -RelatesTo @()
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'AddWhsExtendedPropertyToTableColumn'

    Invoke-RTRivet -Push 'AddWhsExtendedPropertyToTableColumn'

    $expinfo = Get-ExtendedProperties | Sort-Object -Property name

    Assert-Equal $expinfo[0].name 'WHS_ContentType'
    Assert-Equal $expinfo[0].value 'PHIandPII'
    Assert-Equal $expinfo[0].class_desc 'OBJECT_OR_COLUMN'

    Assert-Equal $expinfo[1].name 'WHS_Encrypted'
    Assert-Equal $expinfo[1].value $True
    Assert-Equal $expinfo[1].class_desc 'OBJECT_OR_COLUMN'

    Assert-Equal $expinfo[2].name 'WHS_RelatesTo'
    Assert-Equal $expinfo[2].value ''
    Assert-Equal $expinfo[2].class_desc 'OBJECT_OR_COLUMN'
}
