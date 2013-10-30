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
    
}

'@ | New-Migration -Name 'RemoveExtendedPropertyToView'

    Invoke-Rivet -Push 'RemoveExtendedPropertyToView'

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
    
}

'@ | New-Migration -Name 'RemoveExtendedPropertyToTableColumn'

    Invoke-Rivet -Push 'RemoveExtendedPropertyToTableColumn'

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
    
}

'@ | New-Migration -Name 'RemoveExtendedPropertyToViewColumn'

    Invoke-Rivet -Push 'RemoveExtendedPropertyToViewColumn'

    $expinfo = Get-ExtendedProperties

    Assert-Null $expinfo

}