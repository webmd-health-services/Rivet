function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddDateTime2Column' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldCreateDateTime2Column
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        DateTime2 'id' -Precision 6
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDateTime2Column'

    Invoke-Rivet -Push 'CreateDateTime2Column'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'DateTime2' -TableName 'Foobar' -Precision 26
}

function Test-ShouldCreateDateTime2ColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        DateTime2 'id' -Sparse -Precision 6
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDateTime2ColumnWithSparse'

    Invoke-Rivet -Push 'CreateDateTime2ColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'DateTime2' -TableName 'Foobar' -Sparse -Precision 26
}

function Test-ShouldCreateDateTime2ColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        DateTime2 'id' -NotNull -Precision 6
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDateTime2ColumnWithNotNull'

    Invoke-Rivet -Push 'CreateDateTime2ColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'DateTime2' -TableName 'Foobar' -NotNull -Precision 26
}