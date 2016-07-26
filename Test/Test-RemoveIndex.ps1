
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
    @"
function Push-Migration()
{
    Add-Table -Name 'AddIndex' {
        Int 'IndexMe' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe'

    Remove-Index 'AddIndex' -Name '$(New-ConstraintName -Index 'AddIndex' 'IndexMe')'
}

function Pop-Migration()
{
    Remove-Table 'AddIndex'
}
"@ | New-TestMigration -Name 'RemoveIndex'

    Invoke-RTRivet -Push 'RemoveIndex'
    Assert-True (Test-Table 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe' -TableName 'AddIndex')
    Assert-False (Test-Index -TableName 'AddIndex' -ColumnName 'IndexMe')
}

function Test-ShouldQuoteIndexName
{
    @"
function Push-Migration()
{
    Add-Table -Name 'Remove-Index' {
        Int 'IndexMe' -NotNull
    }

    Add-Index -TableName 'Remove-Index' -ColumnName 'IndexMe'
    Remove-Index -TableName 'Remove-Index' -Name '$(New-ConstraintName -Index 'Remove-Index' 'IndexMe')'
}

function Pop-Migration()
{
    Remove-Table 'Remove-Index'
}
"@ | New-TestMigration -Name 'RemoveIndex'

    Invoke-RTRivet -Push 'RemoveIndex'
    Assert-False (Test-Index -TableName 'Remove-Index' -ColumnName 'IndexMe')
}


function Test-ShouldRemoveUniqueIndex
{
    @"
function Push-Migration()
{
    Add-Table -Name 'AddIndex' {
        Int 'IndexMe' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Unique
    Remove-Index 'AddIndex' -Name '$(New-ConstraintName -Index -Unique 'AddIndex' 'IndexMe')'
}

function Pop-Migration()
{
    Remove-Table 'AddIndex'
}
"@ | New-TestMigration -Name 'RemoveIndex'

    Invoke-RTRivet -Push 'RemoveIndex'
    Assert-True (Test-Table 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe' -TableName 'AddIndex')
    Assert-False (Test-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Unique)
}

function Test-ShouldRemoveIndexWithDefaultName
{
    @"
function Push-Migration()
{
    Add-Table -Name 'AddIndex' {
        Int 'IndexMe' -NotNull
        Int 'IndexMeUnique' -NotNull
    }

    #Add an Index to 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName 'IndexMe'
    Add-Index -TableName 'AddIndex' -ColumnName 'IndexMeUnique' -Unique

    Remove-Index 'AddIndex' 'IndexMe'
    Remove-Index 'AddIndex' 'IndexMeUnique' -Unique
}

function Pop-Migration()
{
    Remove-Table 'AddIndex'
}
"@ | New-TestMigration -Name 'RemoveIndex'

    Invoke-RTRivet -Push 'RemoveIndex'
    Assert-True (Test-Table 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe' -TableName 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMeUnique' -TableName 'AddIndex')
    Assert-False (Test-Index -TableName 'AddIndex' -ColumnName 'IndexMe')
    Assert-False (Test-Index -TableName 'AddIndex' -ColumnName 'IndexMeUnique')
}

