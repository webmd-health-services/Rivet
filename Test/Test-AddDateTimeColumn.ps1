
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateDateTimeColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        DateTime 'id'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateDateTimeColumn'

    Invoke-RTRivet -Push 'CreateDateTimeColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'DateTime' -TableName 'Foobar'
}

function Test-ShouldCreateDateTime2ColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        DateTime 'id' -Sparse
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateDateTimeColumnWithSparse'

    Invoke-RTRivet -Push 'CreateDateTimeColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'DateTime' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateDateTime2ColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        DateTime 'id' -NotNull
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateDateTimeColumnWithNotNull'

    Invoke-RTRivet -Push 'CreateDateTimeColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'DateTime' -TableName 'Foobar' -NotNull
}
