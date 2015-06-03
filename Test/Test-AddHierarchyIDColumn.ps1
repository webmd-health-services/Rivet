
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateHierarchyIDColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        HierarchyID 'id'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateHierarchyIDColumn'

    Invoke-Rivet -Push 'CreateHierarchyIDColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'HierarchyID' -TableName 'Foobar'
}

function Test-ShouldCreateHierarchyIDColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        HierarchyID 'id' -Sparse
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateHierarchyIDColumnWithSparse'

    Invoke-Rivet -Push 'CreateHierarchyIDColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'HierarchyID' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateHierarchyIDColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        HierarchyID 'id' -NotNull
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateHierarchyIDColumnWithNotNull'

    Invoke-Rivet -Push 'CreateHierarchyIDColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'HierarchyID' -TableName 'Foobar' -NotNull
}