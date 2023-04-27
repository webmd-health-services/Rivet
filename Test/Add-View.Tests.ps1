
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-View' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should add view' {
        @'
function Push-Migration
{
     Add-Table -Name 'Person' -Description 'Testing Add-View' -Column {
        VarChar 'FirstName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        VarChar 'LastName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
    } -Option 'data_compression = none'

    Add-View -Name "customView" -Schema "dbo" -Definition "as select FirstName from Person"
}

function Pop-Migration()
{
    Remove-View 'customView'
    Remove-Table 'Person'
}
'@ | New-TestMigration -Name 'AddNewView'
        Invoke-RTRivet -Push 'AddNewView'

        Assert-View -Name "customView" -Schema "dbo" -Definition "as select FirstName from Person"
    }
}
