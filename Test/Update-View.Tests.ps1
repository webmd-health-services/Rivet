
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Update-View' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should update view' {
        @'
function Push-Migration
{
    Add-Table -Name 'Person' -Description 'Testing Add-View' -Column {
        VarChar 'FirstName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        VarChar 'LastName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
    } -Option 'data_compression = none'

    Add-View -Name "customView" -Schema "dbo" -Definition "as select FirstName from Person"
    Update-View -Name "customView" -Schema "dbo" -Definition "as select LastName from Person"
}

function Pop-Migration
{
    Remove-View 'customView'
    Remove-Table 'Person'
}

'@ | New-TestMigration -Name 'UpdateView'

        Invoke-RTRivet -Push 'UpdateView'

        Assert-View -Name "customView" -Schema "dbo" -Definition "as select LastName from Person"
    }
}
