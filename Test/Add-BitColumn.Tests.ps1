
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateBitColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Bit 'id'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateBitColumn'

    Invoke-RTRivet -Push 'CreateBitColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Bit' -TableName 'Foobar'
}

function Test-ShouldCreateBitColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Bit 'id' -Sparse
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateBitColumnWithSparse'

    Invoke-RTRivet -Push 'CreateBitColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Bit' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateBitColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Bit 'id' -NotNull
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateBitColumnWithNotNull'

    Invoke-RTRivet -Push 'CreateBitColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Bit' -TableName 'Foobar' -NotNull
}
