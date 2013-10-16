
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

    #Remove Index
    Remove-Index -TableName 'AddIndex' -ColumnName 'IndexMe'
}

function Pop-Migration()
{
}
'@ | New-Migration -Name 'RemoveIndex'

    Invoke-Rivet -Push 'RemoveIndex'

     ##Assert Table and Column
    Assert-True (Test-Table 'AddIndex')
    Assert-True (Test-Column -Name 'IndexMe' -TableName 'AddIndex')

    ##Assert Index
    Assert-Index -TableName 'AddIndex' -ColumnName 'IndexMe' -TestNoIndex

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
}
'@ | New-Migration -Name 'RemoveIndex'

    Invoke-Rivet -Push 'RemoveIndex'
    Assert-Index -TableName 'Remove-Index' -ColumnName 'IndexMe' -TestNoIndex

}
