function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddCharColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldCreateCharColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Char 'id'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateCharColumn'

    Invoke-Rivet -Push 'CreateCharColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Char' -TableName 'Foobar'
}

function Test-ShouldCreateCharColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Char 'id' -Sparse
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateCharColumnWithSparse'

    Invoke-Rivet -Push 'CreateCharColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Char' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateCharColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Char 'id' -NotNull
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateCharColumnWithNotNull'

    Invoke-Rivet -Push 'CreateCharColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Char' -TableName 'Foobar' -NotNull
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