function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddTimeColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldCreateTimeColumnNonDataTypeSpecific
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        New-Column 'id' -Time
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateTimeColumnNonDataTypeSpecific'

    Invoke-Rivet -Push 'CreateTimeColumnNonDataTypeSpecific'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Time' -TableName 'Foobar'
}

function Test-ShouldCreateTimeColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Time 'id' -Scale 2
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateTimeColumn'

    Invoke-Rivet -Push 'CreateTimeColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Time' -TableName 'Foobar' -Scale 2
}

function Test-ShouldCreateTimeColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Time 'id' -Sparse -Scale 2
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateTimeColumnWithSparse'

    Invoke-Rivet -Push 'CreateTimeColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Time' -TableName 'Foobar' -Sparse -Scale 2
}

function Test-ShouldCreateTimeColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Time 'id' -NotNull -Scale 2
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateTimeColumnWithNotNull'

    Invoke-Rivet -Push 'CreateTimeColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Time' -TableName 'Foobar' -NotNull -Scale 2
}