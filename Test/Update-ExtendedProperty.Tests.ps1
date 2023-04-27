
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
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

'@ | New-TestMigration -Name 'UpdateExtendedPropertyToSchema'

    Invoke-RTRivet -Push 'UpdateExtendedPropertyToSchema'

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

'@ | New-TestMigration -Name 'UpdateExtendedPropertyToTable'

    Invoke-RTRivet -Push 'UpdateExtendedPropertyToTable'

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

'@ | New-TestMigration -Name 'UpdateExtendedPropertyToView'

    Invoke-RTRivet -Push 'UpdateExtendedPropertyToView'

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

'@ | New-TestMigration -Name 'UpdateExtendedPropertyToView'

    Invoke-RTRivet -Push 'UpdateExtendedPropertyToView'

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

'@ | New-TestMigration -Name 'UpdateExtendedPropertyToTableColumn'

    Invoke-RTRivet -Push 'UpdateExtendedPropertyToTableColumn'

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

'@ | New-TestMigration -Name 'UpdateExtendedPropertyToViewColumn'

    Invoke-RTRivet -Push 'UpdateExtendedPropertyToViewColumn'

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

'@ | New-TestMigration -Name 'AllowNullPropertyValue'

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

    Add-ExtendedProperty 'Deploy' 'Goodbye!' -TableName 'Foobar' -ColumnName 'ID'
    Update-ExtendedProperty 'Deploy' '' -TableName 'Foobar' -ColumnName 'ID'
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'AllowEmptyPropertyValue'

    Invoke-RTRivet -Push 'AllowEmptyPropertyValue'

    $expinfo = Get-ExtendedProperties

    Assert-Equal '' $expInfo[0].value

}
