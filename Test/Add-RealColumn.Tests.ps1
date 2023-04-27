
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) 

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateRealColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Real 'id'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateRealColumn'

    Invoke-RTRivet -Push 'CreateRealColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Real' -TableName 'Foobar'
}

function Test-ShouldCreateRealColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Real 'id' -Sparse
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateRealColumnWithSparse'

    Invoke-RTRivet -Push 'CreateRealColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Real' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateRealColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Real 'id' -NotNull
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateRealColumnWithNotNull'

    Invoke-RTRivet -Push 'CreateRealColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Real' -TableName 'Foobar' -NotNull
}
