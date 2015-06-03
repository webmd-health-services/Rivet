
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) 

function Start-Test
{
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
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateCharColumn'

    Invoke-RTRivet -Push 'CreateCharColumn'
    
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
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateCharColumnWithSparse'

    Invoke-RTRivet -Push 'CreateCharColumnWithSparse'
    
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
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateCharColumnWithNotNull'

    Invoke-RTRivet -Push 'CreateCharColumnWithNotNull'
    
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
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'ShouldCreateCharColumnWithCustomSizeCollation'

    Invoke-RTRivet -Push 'ShouldCreateCharColumnWithCustomSizeCollation'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Char' -TableName 'Foobar' -NotNull -Size 50 -Collation "Chinese_Taiwan_Stroke_CI_AS"
}
