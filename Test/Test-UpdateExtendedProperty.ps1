function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'UpdateExtendedProperty' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldUpdateExtendedPropertyToSchema
{
    @'
function Push-Migration
{
    Invoke-Query 'create schema fizz'
    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -SchemaName 'fizz'
    Update-ExtendedProperty -Name 'Deploy' -Value 'FALSE' -SchemaName 'fizz'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'UpdateExtendedPropertyToSchema'

    Invoke-Rivet -Push 'UpdateExtendedPropertyToSchema'

    $expinfo = Get-ExtendedProperties

    Assert-Equal $expinfo[0].name 'Deploy'
    Assert-Equal $expinfo[0].value 'FALSE'
    Assert-Equal $expinfo[0].class_desc 'SCHEMA'

}

function Test-ShouldUpdateExtendedPropertyToTable
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Int ID
    }

    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -TableName 'Foobar' -SchemaName 'dbo'
    Update-ExtendedProperty -Name 'Deploy' -Value 'FALSE' -TableName 'Foobar' -SchemaName 'dbo'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'UpdateExtendedPropertyToTable'

    Invoke-Rivet -Push 'UpdateExtendedPropertyToTable'

    $expinfo = Get-ExtendedProperties

    Assert-Equal 'Deploy' $expinfo[0].name 
    Assert-Equal 'FALSE' $expinfo[0].value 
    Assert-Equal 'OBJECT_OR_COLUMN' $expinfo[0].class_desc

}

function Test-ShouldUpdateExtendedPropertyToColumn
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Int ID
    }

    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -TableName 'Foobar' -SchemaName 'dbo' -ColumnName 'ID'
    Update-ExtendedProperty -Name 'Deploy' -Value 'FALSE' -TableName 'Foobar' -SchemaName 'dbo' -ColumnName 'ID'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'UpdateExtendedPropertyToColumn'

    Invoke-Rivet -Push 'UpdateExtendedPropertyToColumn'

    $expinfo = Get-ExtendedProperties

    Assert-Equal 'Deploy' $expinfo[0].name 
    Assert-Equal 'FALSE' $expinfo[0].value 
    Assert-Equal 'OBJECT_OR_COLUMN' $expinfo[0].class_desc

}