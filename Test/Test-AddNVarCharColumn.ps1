function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'AddNVarCharColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateNVarCharColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        NVarChar 'id' -Max
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateNVarCharColumn'

    Invoke-Rivet -Push 'CreateNVarCharColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'NVarChar' -TableName 'Foobar' -Max
}

function Test-ShouldCreateNVarCharColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        NVarChar 'id' 50 -Sparse
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateNVarCharColumnWithSparse'

    Invoke-Rivet -Push 'CreateNVarCharColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'NVarChar' -TableName 'Foobar' -Sparse -Size 50
}

function Test-ShouldCreateNVarCharColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        NVarChar 'id' -Max -NotNull
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateNVarCharColumnWithNotNull'

    Invoke-Rivet -Push 'CreateNVarCharColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'NVarChar' -TableName 'Foobar' -NotNull -Max
}

function Test-ShouldCreateNVarCharColumnWithSizeCollation
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        NVarChar 'id' -NotNull -Size 50 -Collation "Chinese_Taiwan_Stroke_CI_AS"
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'ShouldCreateNVarCharColumnWithSizeCollation'

    Invoke-Rivet -Push 'ShouldCreateNVarCharColumnWithSizeCollation'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'NVarChar' -TableName 'Foobar' -NotNull -Size 50 -Collation "Chinese_Taiwan_Stroke_CI_AS"
}