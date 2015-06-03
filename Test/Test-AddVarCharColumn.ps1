
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateVarCharColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        VarChar 'id' -Max
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateVarCharColumn'

    Invoke-Rivet -Push 'CreateVarCharColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'VarChar' -TableName 'Foobar' -Max
}

function Test-ShouldCreateVarCharColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        VarChar 'id' -Max -Sparse
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateVarCharColumnWithSparse'

    Invoke-Rivet -Push 'CreateVarCharColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'VarChar' -TableName 'Foobar' -Sparse -Max
}

function Test-ShouldCreateVarCharColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        VarChar 'id' -Max -NotNull
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateVarCharColumnWithNotNull'

    Invoke-Rivet -Push 'CreateVarCharColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'VarChar' -TableName 'Foobar' -NotNull -Max
}

function Test-ShouldCreateVarCharColumnWithCustomSizeCollation
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        VarChar 'id' -NotNull -Size 50 -Collation "Chinese_Taiwan_Stroke_CI_AS"
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'ShouldCreateVarCharColumnWithCustomSizeCollation'

    Invoke-Rivet -Push 'ShouldCreateVarCharColumnWithCustomSizeCollation'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'VarChar' -TableName 'Foobar' -NotNull -Size 50 -Collation "Chinese_Taiwan_Stroke_CI_AS"
}