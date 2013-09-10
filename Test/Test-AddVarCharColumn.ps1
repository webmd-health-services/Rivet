function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddVarCharColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldCreateVarCharColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        VarChar 'id'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateVarCharColumn'

    Invoke-Rivet -Push 'CreateVarCharColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'VarChar' -TableName 'Foobar'
}

function Test-ShouldCreateVarCharColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        VarChar 'id' -Sparse
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateVarCharColumnWithSparse'

    Invoke-Rivet -Push 'CreateVarCharColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'VarChar' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateVarCharColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        VarChar 'id' -NotNull
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateVarCharColumnWithNotNull'

    Invoke-Rivet -Push 'CreateVarCharColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'VarChar' -TableName 'Foobar' -NotNull
}

function Test-ShouldCreateVarCharColumnWithCustomLengthCollation
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        VarChar 'id' -NotNull -Length 50 -Collation "Chinese_Taiwan_Stroke_CI_AS"
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'ShouldCreateVarCharColumnWithCustomLengthCollation'

    Invoke-Rivet -Push 'ShouldCreateVarCharColumnWithCustomLengthCollation'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'VarChar' -TableName 'Foobar' -NotNull -Size 50 -Collation "Chinese_Taiwan_Stroke_CI_AS"
}