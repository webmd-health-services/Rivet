function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddBinaryColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldCreateBinaryColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Binary 'id'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateBinaryColumn'

    Invoke-Rivet -Push 'CreateBinaryColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Binary' -TableName 'Foobar'
}

function Test-ShouldCreateBinaryColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Binary 'id' -Sparse
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateBinaryColumnWithSparse'

    Invoke-Rivet -Push 'CreateBinaryColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Binary' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateBinaryColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Binary 'id' -NotNull
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateBinaryColumnWithNotNull'

    Invoke-Rivet -Push 'CreateBinaryColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Binary' -TableName 'Foobar' -NotNull
}

function Test-ShouldCreateBinaryColumnWithCustomLength
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Binary 'id' -NotNull -Length 50 
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'ShouldCreateBinaryColumnWithCustomLengthCollation'

    Invoke-Rivet -Push 'ShouldCreateBinaryColumnWithCustomLengthCollation'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Binary' -TableName 'Foobar' -NotNull -Size 50 
}