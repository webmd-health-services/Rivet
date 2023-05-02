
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Remove-RowGuidCol' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should remove row guid col' {
        @'
    function Push-Migration
    {
        Add-Table 'Row Guid Col' {
            int 'ID' -NotNull
            uniqueidentifier 'row guid' -rowguidcol
        }

        Remove-RowGuidCol 'Row Guid Col' 'row guid'
    }

    function Pop-Migration
    {
        Remove-Table 'Row Guid Col'
    }
'@ | New-TestMigration -Name 'RemoveRowGuidCol'

        Invoke-RTRivet -Push

        Assert-Column -TableName 'Row Guid Col' -Name 'row guid' -DataType 'uniqueidentifier'
    }

    It 'should remove row guid col in custom schema' {
        @'
    function Push-Migration
    {
        Add-Schema 'custom schema'

        Add-Table -SchemaName 'custom schema' 'Row Guid Col' {
            int 'ID' -NotNull
            uniqueidentifier 'row guid' -rowguidcol
        }

        Remove-RowGuidCol -SchemaName 'custom schema' 'Row Guid Col' 'row guid'
    }

    function Pop-Migration
    {
        Remove-Table -SchemaName 'custom schema' 'Row Guid Col'
        Remove-Schema 'custom schema'
    }
'@ | New-TestMigration -Name 'RemoveRowGuidCol'

        Invoke-RTRivet -Push

        Assert-Column -SchemaName 'custom schema' -TableName 'Row Guid Col' -Name 'row guid' -DataType 'uniqueidentifier'
    }

    It 'should generate idempotent query' {
        @'
    function Push-Migration
    {
        Add-Table 'Row Guid Col' {
            int 'ID' -NotNull
            uniqueidentifier 'row guid' -rowguidcol
        }

        $op = Remove-RowGuidCol 'Row Guid Col' 'row guid'

        Invoke-Ddl -Query $op.ToIdempotentQuery()
        Invoke-Ddl -Query $op.ToIdempotentQuery()
    }

    function Pop-Migration
    {
        Remove-Table 'Row Guid Col'
    }
'@ | New-TestMigration -Name 'RemoveRowGuidCol'

        Invoke-RTRivet -Push

        $Global:Error.Count | Should -Be 0
        Assert-Column -TableName 'Row Guid Col' -Name 'row guid' -DataType 'uniqueidentifier'
    }
}
