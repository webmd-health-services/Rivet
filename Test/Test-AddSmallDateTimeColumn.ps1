function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddSmallDateTimeColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldCreateSmallDateTimeColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        SmallDateTime 'id'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateSmallDateTimeColumn'

    Invoke-Rivet -Push 'CreateSmallDateTimeColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'SmallDateTime' -TableName 'Foobar'
}

function Test-ShouldCreateSmallDateTimeColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        SmallDateTime 'id' -Sparse
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateSmallDateTimeColumnWithSparse'

    Invoke-Rivet -Push 'CreateSmallDateTimeColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'SmallDateTime' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateSmallDateTimeColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        SmallDateTime 'id' -NotNull
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateSmallDateTimeColumnWithNotNull'

    Invoke-Rivet -Push 'CreateSmallDateTimeColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'SmallDateTime' -TableName 'Foobar' -NotNull
}