function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'AddCharColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateCharColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Char 'id' 10
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateCharColumn'

    Invoke-Rivet -Push 'CreateCharColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Char' -TableName 'Foobar' -Size 10
}

function Test-ShouldCreateCharColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Char 'id' 10 -Sparse
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateCharColumnWithSparse'

    Invoke-Rivet -Push 'CreateCharColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Char' -TableName 'Foobar' -Sparse -Size 10
}

function Test-ShouldCreateCharColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Char 'id' 10 -NotNull
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateCharColumnWithNotNull'

    Invoke-Rivet -Push 'CreateCharColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Char' -TableName 'Foobar' -NotNull -Size 10
}

function Test-ShouldCreateCharColumnWithCustomSizeCollation
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Char 'id' -NotNull -Size 50 -Collation "Chinese_Taiwan_Stroke_CI_AS"
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'ShouldCreateCharColumnWithCustomSizeCollation'

    Invoke-Rivet -Push 'ShouldCreateCharColumnWithCustomSizeCollation'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Char' -TableName 'Foobar' -NotNull -Size 50 -Collation "Chinese_Taiwan_Stroke_CI_AS"
}