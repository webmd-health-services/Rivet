function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddDateTimeOffsetColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldCreateDateTimeOffsetColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        DateTimeOffset 'id' -Scale 6
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDateTimeOffsetColumn'

    Invoke-Rivet -Push 'CreateDateTimeOffsetColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'DateTimeOffset' -TableName 'Foobar' -Scale 6
}

function Test-ShouldCreateDateTimeOffsetColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        DateTimeOffset 'id' -Sparse -Scale 6
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDateTimeOffsetColumnWithSparse'

    Invoke-Rivet -Push 'CreateDateTimeOffsetColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'DateTimeOffset' -TableName 'Foobar' -Sparse -Scale 6
}

function Test-ShouldCreateDateTimeOffsetColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        DateTimeOffset 'id' -NotNull -Scale 6
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDateTimeOffsetColumnWithNotNull'

    Invoke-Rivet -Push 'CreateDateTimeOffsetColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'DateTimeOffset' -TableName 'Foobar' -NotNull -Scale 6
}