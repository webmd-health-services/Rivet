
function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RivetTest'
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
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
}

function Pop-Migration()
{
    Remove-Index 'AddIndex' 'IndexMe'
}
'@ | New-Migration -Name 'RemoveIndex'

    Invoke-Rivet -Push 'RemoveIndex'
    Assert-True (Test-Table 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe' -TableName 'AddIndex')
    Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe'

    Invoke-Rivet -Pop
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
}

function Pop-Migration()
{
    Remove-Index -TableName 'Remove-Index' -ColumnName 'IndexMe'
}
'@ | New-Migration -Name 'RemoveIndex'

    Invoke-Rivet -Push 'RemoveIndex'
    Assert-Index -TableName 'Remove-Index' -ColumnName 'IndexMe'

    Invoke-Rivet -Pop
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
}

function Pop-Migration()
{
    Remove-Index -TableName 'Add-Index' -Name 'Example'
}
'@ | New-Migration -Name 'RemoveIndexWithOptionalName'

    Invoke-Rivet -Push 'RemoveIndexWithOptionalName'
    Assert-Index -Name 'Example' -ColumnName 'IndexMe'
    Assert-False (Test-Index -TableName 'Add-Index' -ColumnName 'IndexMe')

    Invoke-Rivet -Pop
    Assert-False (Test-Index -Name 'Example')
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
}

function Pop-Migration()
{
    Remove-Index 'AddIndex' 'IndexMe' -Unique
}
'@ | New-Migration -Name 'RemoveIndex'

    Invoke-Rivet -Push 'RemoveIndex'
    Assert-True (Test-Table 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe' -TableName 'AddIndex')
    Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Unique
    Assert-False (Test-Index -TableName 'AddIndex' -ColumnName 'IndexMe')

    Invoke-Rivet -Pop
    Assert-False (Test-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -Unique)
}