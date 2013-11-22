
function New-ConstraintName
{
    <#
    .SYNOPSIS
    Creates a default constraint name for a column in a table.
    #>
    [CmdletBinding(DefaultParameterSetName='DF')]
    param(
        [Parameter(Mandatory=$true)]
        [string[]]
        # The column name.
        $ColumnName,

        [Parameter(Mandatory=$true)]
        [string]
        # The table name.
        $TableName,

        [Parameter()]
        [string]
        # The table's schema.  Default is `dbo`.
        $SchemaName = 'dbo',

        [Parameter(ParameterSetName='DF')]
        [Switch]
        # Creates a default constraint name.
        $Default,

        [Parameter(Mandatory=$true,ParameterSetName='PK')]
        [Switch]
        # Creates a primary key name.
        $PrimaryKey,

        [Parameter(Mandatory=$true,ParameterSetName='IX')]
        [Switch]
        # Creates an index name.
        $Index,

        [Parameter(Mandatory=$true,ParameterSetName='AK')]
        [Switch]
        # Creates an 'unique' constraint name.
        $Unique,

        [Parameter(Mandatory=$true,ParameterSetName='UIX')]
        [Switch]
        # Creates an 'unique index' constraint name.
        $UniqueIndex
    )

    if ($PSCmdlet.ParameterSetName -eq "DF")
    {
        $op = New-Object 'Rivet.ConstraintName' $SchemaName, $TableName, $ColumnName, Default
        $name = $op.Name
    }

    if ($PSCmdlet.ParameterSetName -eq "PK")
    {
        $op = New-Object 'Rivet.ConstraintName' $SchemaName, $TableName, $ColumnName, PrimaryKey
        $name = $op.Name
    }
    
    if ($PSCmdlet.ParameterSetName -eq "IX")
    {
        $op = New-Object 'Rivet.ConstraintName' $SchemaName, $TableName, $ColumnName, Index
        $name = $op.Name
    }
    if ($PSCmdlet.ParameterSetName -eq "AK")
    {
        $op = New-Object 'Rivet.ConstraintName' $SchemaName, $TableName, $ColumnName, UniqueKey
        $name = $op.Name
    }
    if ($PSCmdlet.ParameterSetName -eq "UIX")
    {
        $op = New-Object 'Rivet.ConstraintName' $SchemaName, $TableName, $ColumnName, UniqueIndex
        $name = $op.Name
    }

    return $name
}