function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'AddDateTimeOffsetColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateDateTimeOffsetColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        DateTimeOffset 'id'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDateTimeOffsetColumn'

    Invoke-Rivet -Push 'CreateDateTimeOffsetColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'DateTimeOffset' -TableName 'Foobar' -Scale 7
}

function Test-ShouldCreateDateTimeOffsetColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        DateTimeOffset 'id' 6 -Sparse 
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDateTimeOffsetColumnWithSparse'

    Invoke-Rivet -Push 'CreateDateTimeOffsetColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'DateTimeOffset' -TableName 'Foobar' -Sparse -Scale 6
}

function Test-ShouldCreateDateTimeOffsetColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        DateTimeOffset 'id' 6 -NotNull
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDateTimeOffsetColumnWithNotNull'

    Invoke-Rivet -Push 'CreateDateTimeOffsetColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'DateTimeOffset' -TableName 'Foobar' -NotNull -Scale 6
}

function Test-ShouldCreateDateTimeOffsetColumnWithNoPrecision
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        DateTimeOffset 'id' -NotNull
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'ShouldCreateDateTimeOffsetColumnWithNoPrecision'

    Invoke-Rivet -Push 'ShouldCreateDateTimeOffsetColumnWithNoPrecision'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'DateTimeOffset' -TableName 'Foobar' -NotNull -Scale 7
}