
function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RivetTest'
    Start-RivetTest
}

function Stop-Test
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

    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -TableName 'Foobar'
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

function Test-ShouldAddExtendedPropertyToView
{
    @'
function Push-Migration
{
    Add-View -SchemaName 'dbo' 'Foobar' 'AS select * from rivet.Migrations'

    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -ViewName 'Foobar'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'AddExtendedPropertyToView'

    Invoke-Rivet -Push 'AddExtendedPropertyToView'

    $expinfo = Get-ExtendedProperties

    Assert-Equal 'Deploy' $expinfo[0].name 
    Assert-Equal 'TRUE' $expinfo[0].value 
    Assert-Equal 'OBJECT_OR_COLUMN' $expinfo[0].class_desc

}


function Test-ShouldAddExtendedPropertyToViewInCustomSchema
{
    @'
function Push-Migration
{
    Add-Schema 'metric'
    Add-View -SchemaName 'metric' 'Foobar' 'AS select * from rivet.Migrations'

    Add-ExtendedProperty 'Deploy' 'TRUE' -SchemaName 'metric' -ViewName 'Foobar'
}

function Pop-Migration
{
}

'@ | New-Migration -Name 'AddExtendedPropertyToView'

    Invoke-Rivet -Push 'AddExtendedPropertyToView'

    $expinfo = Get-ExtendedProperties

    Assert-Equal 'Deploy' $expinfo[0].name 
    Assert-Equal 'TRUE' $expinfo[0].value 
    Assert-Equal 'OBJECT_OR_COLUMN' $expinfo[0].class_desc

}

function Test-ShouldAddExtendedPropertyToTableColumn
{
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
    
}

'@ | New-Migration -Name 'AddExtendedPropertyToTableColumn'

    Invoke-Rivet -Push 'AddExtendedPropertyToTableColumn'

    $expinfo = Get-ExtendedProperties

    Assert-Equal 'Deploy' $expinfo[0].name 
    Assert-Equal 'TRUE' $expinfo[0].value 
    Assert-Equal 'OBJECT_OR_COLUMN' $expinfo[0].class_desc

}

function Test-ShouldAddExtendedPropertyToViewColumn
{
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
    
}

'@ | New-Migration -Name 'AddExtendedPropertyToViewColumn'

    Invoke-Rivet -Push 'AddExtendedPropertyToViewColumn'

    $expinfo = Get-ExtendedProperties

    Assert-Equal 'Deploy' $expinfo[0].name 
    Assert-Equal 'TRUE' $expinfo[0].value 
    Assert-Equal 'OBJECT_OR_COLUMN' $expinfo[0].class_desc

}

function Test-ShouldAllowNullPropertyValue
{
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
    
}

'@ | New-Migration -Name 'AllowNullPropertyValue'

    Invoke-Rivet -Push 'AllowNullPropertyValue'

    $expinfo = Get-ExtendedProperties

    Assert-Null $expInfo[0].value
}


function Test-ShouldAllowEmptyPropertyValue
{
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
    
}

'@ | New-Migration -Name 'AddExtendedPropertyToColumn'

    Invoke-Rivet -Push 'AddExtendedPropertyToColumn'

    $expinfo = Get-ExtendedProperties

    Assert-Equal '' $expInfo[0].value

}