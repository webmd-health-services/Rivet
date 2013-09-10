function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddNVarCharColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldCreateNVarCharColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        NVarChar 'id'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateNVarCharColumn'

    Invoke-Rivet -Push 'CreateNVarCharColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'NVarChar' -TableName 'Foobar'
}

function Test-ShouldCreateNVarCharColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        NVarChar 'id' -Sparse
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateNVarCharColumnWithSparse'

    Invoke-Rivet -Push 'CreateNVarCharColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'NVarChar' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateNVarCharColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        NVarChar 'id' -NotNull
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateNVarCharColumnWithNotNull'

    Invoke-Rivet -Push 'CreateNVarCharColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'NVarChar' -TableName 'Foobar' -NotNull
}

function Test-ShouldCreateNVarCharColumnWithLengthCollation
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        NVarChar 'id' -NotNull -Length 50 -Collation "Chinese_Taiwan_Stroke_CI_AS"
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'ShouldCreateNVarCharColumnWithLengthCollation'

    Invoke-Rivet -Push 'ShouldCreateNVarCharColumnWithLengthCollation'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'NVarChar' -TableName 'Foobar' -NotNull -Size 50 -Collation "Chinese_Taiwan_Stroke_CI_AS"
}