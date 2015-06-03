function Setup
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'UpdateExtendedProperty' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
}

function Test-ShouldUpdateExtendedPropertyToSchema
{
    @'
function Push-Migration
{
    Add-Schema 'fizz'
    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -SchemaName 'fizz'
    Update-ExtendedProperty -Name 'Deploy' -Value 'FALSE' -SchemaName 'fizz'
}

function Pop-Migration
{
    Remove-Schema 'fizz'
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

    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -TableName 'Foobar' 
    Update-ExtendedProperty -Name 'Deploy' -Value 'FALSE' -TableName 'Foobar' 
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'UpdateExtendedPropertyToTable'

    Invoke-Rivet -Push 'UpdateExtendedPropertyToTable'

    $expinfo = Get-ExtendedProperties

    Assert-Equal 'Deploy' $expinfo[0].name 
    Assert-Equal 'FALSE' $expinfo[0].value 
    Assert-Equal 'OBJECT_OR_COLUMN' $expinfo[0].class_desc

}


function Test-ShouldUpdateExtendedPropertyToView
{
    @'
function Push-Migration
{
    Add-View -SchemaName 'dbo' 'Foobar' 'AS select * from rivet.Migrations'

    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -ViewName 'Foobar'

    Update-ExtendedProperty -Name 'Deploy' -Value 'FALSE' -ViewName 'Foobar' 
}

function Pop-Migration
{
    Remove-View 'Foobar'
}

'@ | New-Migration -Name 'UpdateExtendedPropertyToView'

    Invoke-Rivet -Push 'UpdateExtendedPropertyToView'

    $expinfo = Get-ExtendedProperties

    Assert-Equal 'Deploy' $expinfo[0].name 
    Assert-Equal 'FALSE' $expinfo[0].value 
    Assert-Equal 'OBJECT_OR_COLUMN' $expinfo[0].class_desc

}


function Test-ShouldUpdateExtendedPropertyToViewInCustomSchema
{
    @'
function Push-Migration
{
    Add-Schema 'metric'
    Add-View -SchemaName 'metric' 'Foobar' 'AS select * from rivet.Migrations'
    Add-ExtendedProperty 'Deploy' 'TRUE' -SchemaName 'metric' -ViewName 'Foobar'
    Update-ExtendedProperty 'Deploy' 'FALSE' -SchemaName 'metric' -ViewName 'Foobar' 
}

function Pop-Migration
{
    Remove-View 'Foobar' -schemaname 'metric'
    Remove-Schema 'metric'
}

'@ | New-Migration -Name 'UpdateExtendedPropertyToView'

    Invoke-Rivet -Push 'UpdateExtendedPropertyToView'

    $expinfo = Get-ExtendedProperties

    Assert-Equal 'Deploy' $expinfo[0].name 
    Assert-Equal 'FALSE' $expinfo[0].value 
    Assert-Equal 'OBJECT_OR_COLUMN' $expinfo[0].class_desc

}


function Test-ShouldUpdateExtendedPropertyToTableColumn
{
    @'
function Push-Migration
{
    Add-Table Foobar {
        Int ID
    }

    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -TableName 'Foobar' -ColumnName 'ID'
    Update-ExtendedProperty -Name 'Deploy' -Value 'FALSE' -TableName 'Foobar' -ColumnName 'ID'
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'UpdateExtendedPropertyToTableColumn'

    Invoke-Rivet -Push 'UpdateExtendedPropertyToTableColumn'

    $expinfo = Get-ExtendedProperties

    Assert-Equal 'Deploy' $expinfo[0].name 
    Assert-Equal 'FALSE' $expinfo[0].value 
    Assert-Equal 'OBJECT_OR_COLUMN' $expinfo[0].class_desc

}


function Test-ShouldUpdateExtendedPropertyToViewColumn
{
    @'
function Push-Migration
{
    Add-Table Table {
        Int ID
    }

    Add-View -SchemaName 'dbo' 'Foobar' 'AS select * from rivet.Migrations'

    Add-ExtendedProperty -Name 'Deploy' -Value 'TRUE' -ViewName 'Foobar' -ColumnName 'ID'
    Update-ExtendedProperty -Name 'Deploy' -Value 'FALSE' -ViewName 'Foobar' -ColumnName 'ID'
}

function Pop-Migration
{
    Remove-View 'Foobar'
    Remove-Table 'Table'
}

'@ | New-Migration -Name 'UpdateExtendedPropertyToViewColumn'

    Invoke-Rivet -Push 'UpdateExtendedPropertyToViewColumn'

    $expinfo = Get-ExtendedProperties

    Assert-Equal 'Deploy' $expinfo[0].name 
    Assert-Equal 'FALSE' $expinfo[0].value 
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

    Add-ExtendedProperty 'Deploy' 'Goodbye!' -TableName 'Foobar' -ColumnName 'ID'
    Update-ExtendedProperty 'Deploy' $null -TableName 'Foobar' -ColumnName 'ID'
}

function Pop-Migration
{
    Remove-Table 'Foobar'
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

    Add-ExtendedProperty 'Deploy' 'Goodbye!' -TableName 'Foobar' -ColumnName 'ID'
    Update-ExtendedProperty 'Deploy' '' -TableName 'Foobar' -ColumnName 'ID'
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'AllowEmptyPropertyValue'

    Invoke-Rivet -Push 'AllowEmptyPropertyValue'

    $expinfo = Get-ExtendedProperties

    Assert-Equal '' $expInfo[0].value

}