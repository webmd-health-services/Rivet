
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
}

function Pop-Migration()
{
    Remove-ForeignKey 'Source' 'Reference'
}
'@ | New-Migration -Name 'RemoveForeignKey'
    Invoke-Rivet -Push "RemoveForeignKey"
    Assert-ForeignKey -TableName 'Source' -References 'Reference'

    Invoke-Rivet -Pop
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
}

function Pop-Migration()
{
    Remove-ForeignKey -TableName 'Remove-ForeignKey' -References 'Reference'
}
'@ | New-Migration -Name 'RemoveForeignKey'
    Invoke-Rivet -Push "RemoveForeignKey"
    Assert-ForeignKey -TableName 'Remove-ForeignKey' -References 'Reference'

    Invoke-Rivet -Pop
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
}

function Pop-Migration()
{
    Remove-ForeignKey 'Source' -Name 'Optional'
}
'@ | New-Migration -Name 'RemoveForeignKeyWithOptionalName'
    Invoke-Rivet -Push "RemoveForeignKeyWithOptionalName"

    Invoke-Rivet -Pop
    
    $ForeignKeys = Invoke-RivetTestQuery -Query 'select * from sys.foreign_keys'

    Assert-Null $ForeignKeys
}