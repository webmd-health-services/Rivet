function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddExtendedProperty' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldAddExtendedPropertyToSchema
{
    @'
function Push-Migration
{
    Invoke-Query 'create schema fizz'
    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -SchemaName 'fizz'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'AddExtendedPropertyToSchema'

    Invoke-Rivet -Push 'AddExtendedPropertyToSchema'

    $expinfo = Get-ExtendedProperties

    Assert-Equal $expinfo[0].name 'Deploy'
    Assert-Equal $expinfo[0].value 'TRUE'
    Assert-Equal $expinfo[0].class_desc 'SCHEMA'

}

function Test-ShouldAddExtendedPropertyToTable
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Int ID
    }

    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -TableName 'Foobar' -SchemaName 'dbo'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'AddExtendedPropertyToTable'

    Invoke-Rivet -Push 'AddExtendedPropertyToTable'

    $expinfo = Get-ExtendedProperties

    Assert-Equal 'Deploy' $expinfo[0].name 
    Assert-Equal 'TRUE' $expinfo[0].value 
    Assert-Equal 'OBJECT_OR_COLUMN' $expinfo[0].class_desc

}

function Test-ShouldAddExtendedPropertyToColumn
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Int ID
    }

    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -TableName 'Foobar' -SchemaName 'dbo' -ColumnName 'ID'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'AddExtendedPropertyToColumn'

    Invoke-Rivet -Push 'AddExtendedPropertyToColumn'

    $expinfo = Get-ExtendedProperties

    Assert-Equal 'Deploy' $expinfo[0].name 
    Assert-Equal 'TRUE' $expinfo[0].value 
    Assert-Equal 'OBJECT_OR_COLUMN' $expinfo[0].class_desc

}