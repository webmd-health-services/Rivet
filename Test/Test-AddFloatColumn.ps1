function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddFloatColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldCreateFloatColumnNonDataTypeSpecific
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        New-Column 'id' -Float
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateFloatColumnNonDataTypeSpecific'

    Invoke-Rivet -Push 'CreateFloatColumnNonDataTypeSpecific'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Float' -TableName 'Foobar'
}

function Test-ShouldCreateFloatColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Float 'id' -Precision 53
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateFloatColumn'

    Invoke-Rivet -Push 'CreateFloatColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Float' -TableName 'Foobar'
}

function Test-ShouldCreateFloatColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Float 'id' -Sparse -Precision 53
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateFloatColumnWithSparse'

    Invoke-Rivet -Push 'CreateFloatColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Float' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateFloatColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Float 'id' -NotNull -Precision 53
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateFloatColumnWithNotNull'

    Invoke-Rivet -Push 'CreateFloatColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Float' -TableName 'Foobar' -NotNull
}