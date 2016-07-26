
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldAddRowGuidCol
{
    @'
function Push-Migration
{
    Add-Table 'Row Guid Col' {
        int 'ID' -NotNull
        uniqueidentifier 'row guid'
    }

    Add-RowGuidCol 'Row Guid Col' 'row guid'
}

function Pop-Migration
{
    Remove-Table 'Row Guid Col'
}
'@ | New-TestMigration -Name 'AddRowGuidCol'

    Invoke-RTRivet -Push

    Assert-Column -TableName 'Row Guid Col' -Name 'row guid' -DataType 'uniqueidentifier' -RowGuidCol
}

function Test-ShouldAddRowGuidColInCustomSchema
{
    @'
function Push-Migration
{
    Add-Schema 'custom schema'

    Add-Table -SchemaName 'custom schema' 'Row Guid Col' {
        int 'ID' -NotNull
        uniqueidentifier 'row guid'
    }

    Add-RowGuidCol -SchemaName 'custom schema' 'Row Guid Col' 'row guid'
}

function Pop-Migration
{
    Remove-Table -SchemaName 'custom schema' 'Row Guid Col'
    Remove-Schema 'custom schema'
}
'@ | New-TestMigration -Name 'AddRowGuidCol'

    Invoke-RTRivet -Push

    Assert-Column -SchemaName 'custom schema' -TableName 'Row Guid Col' -Name 'row guid' -DataType 'uniqueidentifier' -RowGuidCol
}

function Test-ShouldGenerateIdempotentQuery
{
    @'
function Push-Migration
{
    Add-Table 'Row Guid Col' {
        int 'ID' -NotNull
        uniqueidentifier 'row guid'
    }

    $op = Add-RowGuidCol 'Row Guid Col' 'row guid'

    Invoke-Ddl -Query $op.ToIdempotentQuery()
    Invoke-Ddl -Query $op.ToIdempotentQuery()
}

function Pop-Migration
{
    Remove-Table 'Row Guid Col'
}
'@ | New-TestMigration -Name 'AddRowGuidCol'

    Invoke-RTRivet -Push -Verbose

    Assert-NoError
    Assert-Column -TableName 'Row Guid Col' -Name 'row guid' -DataType 'uniqueidentifier' -RowGuidCol    
}
