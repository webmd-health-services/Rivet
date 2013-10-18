
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

function Test-ShouldAddForeignKeyFromSingleColumnToSingleColumn
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
    Add-ForeignKey 'Source' 'source_id' 'Reference' 'reference_id'
}

function Pop-Migration()
{
}
'@ | New-Migration -Name 'AddForeignKeyFromSingleColumnToSingleColumn'
    Invoke-Rivet -Push 'AddForeignKeyFromSingleColumnToSingleColumn'
    Assert-ForeignKey -TableName 'Source' -References 'Reference'
}

function Test-ShouldAddForeignKeyFromMultipleColumnToMultipleColumn
{
    @'
function Push-Migration()
{
    Add-Table -Name 'Source' {
        Int 's_id_1' -NotNull
        Int 's_id_2' -NotNull
    }

    Add-Table -Name 'Reference' {
        Int 'r_id_1' -NotNull
        Int 'r_id_2' -NotNull
    }

    Add-PrimaryKey -TableName 'Reference' -ColumnName 'r_id_1','r_id_2'
    Add-ForeignKey -TableName 'Source' -ColumnName 's_id_1','s_id_2' -References 'Reference' -ReferencedColumn 'r_id_1','r_id_2'
}

function Pop-Migration()
{
}
'@ | New-Migration -Name 'AddForeignKeyFromMultipleColumnToMultipleColumn'
    Invoke-Rivet -Push 'AddForeignKeyFromMultipleColumnToMultipleColumn'
    Assert-ForeignKey -TableName 'Source' -References 'Reference'
}

function Test-ShouldAddForeignKeyWithCustomSchema
{
    @'
function Push-Migration()
{
    Add-Table -Name 'Source' -SchemaName 'rivet' {
        Int 'source_id' -NotNull
    }

    Add-Table -Name 'Reference' -SchemaName 'rivet' {
        Int 'reference_id' -NotNull
    }

    Add-PrimaryKey -TableName 'Reference' -ColumnName 'reference_id' -SchemaName 'rivet'
    Add-ForeignKey -TableName 'Source' -SchemaName 'rivet' -ColumnName 'source_id' -References 'Reference' -ReferencesSchema 'rivet' -ReferencedColumn 'reference_id'
}

function Pop-Migration()
{
}
'@ | New-Migration -Name 'AddForeignKeyWithCustomSchema'
    Invoke-Rivet -Push 'AddForeignKeyWithCustomSchema'
    Assert-ForeignKey -TableName 'Source' -SchemaName 'rivet' -References 'Reference' -ReferencesSchema 'rivet'
}

function Test-ShouldAddForeignKeyWithOnDelete
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
    Add-ForeignKey -TableName 'Source' -ColumnName 'source_id' -References 'Reference' -ReferencedColumn 'reference_id' -OnDelete 'CASCADE'
}

function Pop-Migration()
{
}
'@ | New-Migration -Name 'AddForeignKeyWithOnDelete'
    Invoke-Rivet -Push 'AddForeignKeyWithOnDelete'
    Assert-ForeignKey -TableName 'Source' -References 'Reference' -OnDelete 'CASCADE'

}

function Test-ShouldAddForeignKeyWithOnUpdate
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
    Add-ForeignKey -TableName 'Source' -ColumnName 'source_id' -References 'Reference' -ReferencedColumn 'reference_id' -OnDelete 'CASCADE' -OnUpdate 'CASCADE'
}

function Pop-Migration()
{
}
'@ | New-Migration -Name 'AddForeignKeyWithOnUpdate'
    Invoke-Rivet -Push 'AddForeignKeyWithOnUpdate'
    Assert-ForeignKey -TableName 'Source' -References 'Reference' -OnDelete 'CASCADE' -OnUpdate 'CASCADE'
}

function Test-ShouldAddForeignKeyNotForReplication
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
    Add-ForeignKey -TableName 'Source' -ColumnName 'source_id' -References 'Reference' -ReferencedColumn 'reference_id' -OnDelete 'CASCADE' -OnUpdate 'CASCADE' -NotForReplication
}

function Pop-Migration()
{
}
'@ | New-Migration -Name 'AddForeignKeyNotForReplication'
    Invoke-Rivet -Push 'AddForeignKeyNotForReplication'
    Assert-ForeignKey -TableName 'Source' -References 'Reference' -OnDelete 'CASCADE' -OnUpdate 'CASCADE' -NotForReplication

}

function Test-ShouldQuoteForeignKeyName
{
    @'
function Push-Migration()
{
    Add-Table -Name 'Add-ForeignKey' {
        Int 'source_id' -NotNull
    }

    Add-Table -Name 'Reference' {
        Int 'reference_id' -NotNull
    }

    Add-PrimaryKey -TableName 'Reference' -ColumnName 'reference_id'
    Add-ForeignKey -TableName 'Add-ForeignKey' -ColumnName 'source_id' -References 'Reference' -ReferencedColumn 'reference_id'
}

function Pop-Migration()
{
}
'@ | New-Migration -Name 'AddForeignKeyFromSingleColumnToSingleColumn'
    Invoke-Rivet -Push 'AddForeignKeyFromSingleColumnToSingleColumn'
    Assert-ForeignKey -TableName 'Add-ForeignKey' -References 'Reference'
}

