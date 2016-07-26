
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldRemoveRowGuidCol
{
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

function Test-ShouldRemoveRowGuidColInCustomSchema
{
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

function Test-ShouldGenerateIdempotentQuery
{
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

    Assert-NoError
    Assert-Column -TableName 'Row Guid Col' -Name 'row guid' -DataType 'uniqueidentifier'
}
