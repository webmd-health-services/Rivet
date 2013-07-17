
function Assert-PrimaryKey
{
    <#
    .SYNOPSIS
    Tests that a primary key exists and the columns that are a part of it.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table whose primary key to get.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string[]]
        # The column(s) that are part of the primary key.
        $ColumnName
    )

    $pk = Get-PrimaryKey -TableName $TableName -SchemaName $SchemaName
    Assert-NotNull $pk ('Primary Key on table {0}.{1} doesn''t exist.' -f $SchemaName,$TableName)
    
    $name = New-ConstraintName -TableName $TableName -SchemaName $SchemaName -ColumnName $ColumnName -PrimaryKey
    Assert-Equal $name $pk.name

    $ColumnName = [Object[]]$ColumnName
    $pk = [Object[]]$pk

    Assert-Equal $ColumnName.Count $pk.Count
    for( $idx = 0; $idx -lt $ColumnName.Count; ++$idx )
    {
        $ordinal = $idx + 1
        Assert-Equal $ColumnName[$idx] $pk[$idx].ColumnName ('{0}.{1}: Unexpected column at ordinal {2}' -f $SchemaName,$TableName,$ordinal)
        Assert-Equal $ordinal $pk[$idx].key_ordinal
    }
}