function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RemoveExtendedProperty' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldRemoveExtendedPropertyToSchema
{
    @'
function Push-Migration
{
    Invoke-Query 'create schema fizz'
    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -SchemaName 'fizz'
    Remove-ExtendedProperty -Name 'Deploy' -SchemaName 'fizz'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'RemoveExtendedPropertyToSchema'

    Invoke-Rivet -Push 'RemoveExtendedPropertyToSchema'

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
    
}

'@ | New-Migration -Name 'RemoveExtendedPropertyToTable'

    Invoke-Rivet -Push 'RemoveExtendedPropertyToTable'

    $expinfo = Get-ExtendedProperties

    Assert-Null $expinfo

}

function Test-ShouldRemoveExtendedPropertyToColumn
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
    
}

'@ | New-Migration -Name 'RemoveExtendedPropertyToColumn'

    Invoke-Rivet -Push 'RemoveExtendedPropertyToColumn'

    $expinfo = Get-ExtendedProperties

    Assert-Null $expinfo

}