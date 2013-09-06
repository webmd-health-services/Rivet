function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddBitColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldCreateBitColumnNonDataTypeSpecific
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        New-Column 'id' -Bit
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateBitColumnNonDataTypeSpecific'

    Invoke-Rivet -Push 'CreateBitColumnNonDataTypeSpecific'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Bit' -TableName 'Foobar'
}

function Test-ShouldCreateBitColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Bit 'id'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateBitColumn'

    Invoke-Rivet -Push 'CreateBitColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Bit' -TableName 'Foobar'
}

function Test-ShouldCreateBitColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Bit 'id' -Sparse
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateBitColumnWithSparse'

    Invoke-Rivet -Push 'CreateBitColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Bit' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateBitColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Bit 'id' -NotNull
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateBitColumnWithNotNull'

    Invoke-Rivet -Push 'CreateBitColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Bit' -TableName 'Foobar' -NotNull
}