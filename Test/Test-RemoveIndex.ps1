
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldRemoveIndex
{
    @'
function Push-Migration()
{
    Add-Table -Name 'AddIndex' {
        Int 'IndexMe' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe'

    Remove-Index 'AddIndex' 'IndexMe'
}

function Pop-Migration()
{
    Remove-Table 'AddIndex'
}
'@ | New-Migration -Name 'RemoveIndex'

    Invoke-RTRivet -Push 'RemoveIndex'
    Assert-True (Test-Table 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe' -TableName 'AddIndex')
    Assert-False (Test-Index -TableName 'AddIndex' -ColumnName 'IndexMe')
}

function Test-ShouldQuoteIndexName
{
    @'
function Push-Migration()
{
    Add-Table -Name 'Remove-Index' {
        Int 'IndexMe' -NotNull
    }

    Add-Index -TableName 'Remove-Index' -ColumnName 'IndexMe'
    Remove-Index -TableName 'Remove-Index' -ColumnName 'IndexMe'
}

function Pop-Migration()
{
    Remove-Table 'Remove-Index'
}
'@ | New-Migration -Name 'RemoveIndex'

    Invoke-RTRivet -Push 'RemoveIndex'
    Assert-False (Test-Index -TableName 'Remove-Index' -ColumnName 'IndexMe')
}

function Test-ShouldRemoveIndexWithOptionalName
{
    @'
function Push-Migration()
{
    Add-Table -Name 'Add-Index' {
        Int 'IndexMe' -NotNull
    }

    Add-Index -TableName 'Add-Index' -ColumnName 'IndexMe' -Name 'Example'
    Remove-Index -TableName 'Add-Index' -Name 'Example'
}

function Pop-Migration()
{
    Remove-Table 'Add-Index'
}
'@ | New-Migration -Name 'RemoveIndexWithOptionalName'

    Invoke-RTRivet -Push 'RemoveIndexWithOptionalName'
    Assert-False (Test-Index -TableName 'Add-Index' -ColumnName 'IndexMe')
}

function Test-ShouldRemoveUniqueIndex
{
    @'
function Push-Migration()
{
    Add-Table -Name 'AddIndex' {
        Int 'IndexMe' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Unique
    Remove-Index 'AddIndex' 'IndexMe' -Unique
}

function Pop-Migration()
{
    Remove-Table 'AddIndex'
}
'@ | New-Migration -Name 'RemoveIndex'

    Invoke-RTRivet -Push 'RemoveIndex'
    Assert-True (Test-Table 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe' -TableName 'AddIndex')
    Assert-False (Test-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Unique)
}
