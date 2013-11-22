function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddDateTimeColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
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
    
}

'@ | New-Migration -Name 'CreateDateTimeColumn'

    Invoke-Rivet -Push 'CreateDateTimeColumn'
    
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
    
}

'@ | New-Migration -Name 'CreateDateTimeColumnWithSparse'

    Invoke-Rivet -Push 'CreateDateTimeColumnWithSparse'
    
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
    
}

'@ | New-Migration -Name 'CreateDateTimeColumnWithNotNull'

    Invoke-Rivet -Push 'CreateDateTimeColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'DateTime' -TableName 'Foobar' -NotNull
}