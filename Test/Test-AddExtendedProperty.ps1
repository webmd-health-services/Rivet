
function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'RivetTest' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldAddExtendedPropertyToSchema
{
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

'@ | New-Migration -Name 'AddExtendedPropertyToSchema'

    Invoke-RTRivet -Push 'AddExtendedPropertyToSchema'

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
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'AddExtendedPropertyToTable'

    Invoke-RTRivet -Push 'AddExtendedPropertyToTable'

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
    Remove-View 'Foobar'
}

'@ | New-Migration -Name 'AddExtendedPropertyToView'

    Invoke-RTRivet -Push 'AddExtendedPropertyToView'

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
    Remove-View 'Foobar' -SchemaName 'metric'
    Remove-Schema 'metric'
}

'@ | New-Migration -Name 'AddExtendedPropertyToView'

    Invoke-RTRivet -Push 'AddExtendedPropertyToView'

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
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'AddExtendedPropertyToTableColumn'

    Invoke-RTRivet -Push 'AddExtendedPropertyToTableColumn'

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
    Remove-View 'Foobar'
    Remove-Table 'Table'
}

'@ | New-Migration -Name 'AddExtendedPropertyToViewColumn'

    Invoke-RTRivet -Push 'AddExtendedPropertyToViewColumn'

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
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'AllowNullPropertyValue'

    Invoke-RTRivet -Push 'AllowNullPropertyValue'

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
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'AddExtendedPropertyToColumn'

    Invoke-RTRivet -Push 'AddExtendedPropertyToColumn'

    $expinfo = Get-ExtendedProperties

    Assert-Equal '' $expInfo[0].value

}
