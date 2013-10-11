function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddVarBinaryColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldCreateVarBinaryColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        VarBinary 'id' -Max
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateVarBinaryColumn'

    Invoke-Rivet -Push 'CreateVarBinaryColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'VarBinary' -TableName 'Foobar' -Max
}

# This test won't work unless file streams are setup.  Don't know how to do that so ignoring this test for now.
function Ignore-ShouldCreateVarBinaryColumnWithFileStream
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        VarBinary 'id' -Max -FileStream "default"
    } -FileStreamFileGroup "default"
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateVarBinaryColumnWithFileStream'

    Invoke-Rivet -Push 'CreateVarBinaryColumnWithFileStream'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'VarBinary' -TableName 'Foobar' -Max
}

function Test-ShouldCreateVarBinaryColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        VarBinary 'id' -Max -NotNull
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateVarBinaryColumnWithNotNull'

    Invoke-Rivet -Push 'CreateVarBinaryColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'VarBinary' -TableName 'Foobar' -NotNull -Max
}

function Test-ShouldCreateVarBinaryColumnWithCustomSize
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        VarBinary 'id' 50 -NotNull
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'ShouldCreateVarBinaryColumnWithCustomSize'

    Invoke-Rivet -Push 'ShouldCreateVarBinaryColumnWithCustomSize'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'VarBinary' -TableName 'Foobar' -NotNull -Size 50 
}