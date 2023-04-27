
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateSmallDateTimeColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        SmallDateTime 'id'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateSmallDateTimeColumn'

    Invoke-RTRivet -Push 'CreateSmallDateTimeColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'SmallDateTime' -TableName 'Foobar'
}

function Test-ShouldCreateSmallDateTimeColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        SmallDateTime 'id' -Sparse
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateSmallDateTimeColumnWithSparse'

    Invoke-RTRivet -Push 'CreateSmallDateTimeColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'SmallDateTime' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateSmallDateTimeColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        SmallDateTime 'id' -NotNull
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateSmallDateTimeColumnWithNotNull'

    Invoke-RTRivet -Push 'CreateSmallDateTimeColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'SmallDateTime' -TableName 'Foobar' -NotNull
}
