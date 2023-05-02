
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Update-StoredProcedure' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should update existing stored procedure' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Person' -Description 'Testing Add-StoredProcedure' -Column {
            VarChar 'FirstName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
            VarChar 'MiddleName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
            VarChar 'LastName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        } -Option 'data_compression = none'

        Add-StoredProcedure -Name 'TestStoredProcedure' -Definition 'as SELECT FirstName, LastName FROM dbo.Person;' -SchemaName 'dbo'
        Update-StoredProcedure -Name 'TestStoredProcedure' -Definition 'as SELECT MiddleName, LastName FROM dbo.Person;' -SchemaName 'dbo'
    }

    function Pop-Migration
    {
        Remove-StoredProcedure 'TestStoredProcedure'
        Remove-Table 'Person'
    }

'@ | New-TestMigration -Name 'UpdateExistingStoredProcedure'

        Invoke-RTRivet -Push 'UpdateExistingStoredProcedure'

        Assert-StoredProcedure -Name 'TestStoredProcedure' -Definition 'as SELECT MiddleName, LastName FROM dbo.Person;' -SchemaName 'dbo'
    }
}
