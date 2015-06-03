
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldRemoveForeignKey
{
    @'
function Push-Migration()
{
    Add-Table -Name 'Source' {
        Int 'source_id' -NotNull
    }

    Add-Table -Name 'Reference' {
        Int 'reference_id' -NotNull
    }

    Add-PrimaryKey -TableName 'Reference' -ColumnName 'reference_id'
    Add-ForeignKey -TableName 'Source' -ColumnName 'source_id' -References 'Reference' -ReferencedColumn 'reference_id'
    Remove-ForeignKey 'Source' 'Reference'
}

function Pop-Migration()
{
    Remove-Table 'Reference'
    Remove-Table 'Source'
}
'@ | New-Migration -Name 'RemoveForeignKey'
    Invoke-Rivet -Push "RemoveForeignKey"
    Assert-False (Test-ForeignKey -TableName 'Source' -References 'Reference')
}

function Test-ShouldQuoteForeignKeyName
{
    @'
function Push-Migration()
{
    Add-Table -Name 'Remove-ForeignKey' {
        Int 'source_id' -NotNull
    }

    Add-Table -Name 'Reference' {
        Int 'reference_id' -NotNull
    }

    Add-PrimaryKey -TableName 'Reference' -ColumnName 'reference_id'
    Add-ForeignKey -TableName 'Remove-ForeignKey' -ColumnName 'source_id' -References 'Reference' -ReferencedColumn 'reference_id'
    Remove-ForeignKey -TableName 'Remove-ForeignKey' -References 'Reference'
}

function Pop-Migration()
{
    Remove-Table 'Reference'
    Remove-Table 'Remove-ForeignKey'
}
'@ | New-Migration -Name 'RemoveForeignKey'
    Invoke-Rivet -Push "RemoveForeignKey"
    Assert-False (Test-ForeignKey -TableName 'Remove-ForeignKey' -References 'Reference')
}

function Test-ShouldRemoveForeignKeyWithOptionalName
{
    @'
function Push-Migration()
{
    Add-Table -Name 'Source' {
        Int 'source_id' -NotNull
    }

    Add-Table -Name 'Reference' {
        Int 'reference_id' -NotNull
    }

    Add-PrimaryKey -TableName 'Reference' -ColumnName 'reference_id'
    Add-ForeignKey -TableName 'Source' -ColumnName 'source_id' -References 'Reference' -ReferencedColumn 'reference_id' -Name 'Optional'
    Remove-ForeignKey 'Source' -Name 'Optional'
}

function Pop-Migration()
{
    Remove-Table 'Reference'
    Remove-Table 'Source'
}
'@ | New-Migration -Name 'RemoveForeignKeyWithOptionalName'
    Invoke-Rivet -Push "RemoveForeignKeyWithOptionalName"
    $ForeignKeys = Invoke-RivetTestQuery -Query 'select * from sys.foreign_keys'
    Assert-Null $ForeignKeys
}