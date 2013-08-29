
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

        [Parameter(Mandatory=$true,ParameterSetName='UQ')]
        [Switch]
        # Creates an 'unique' constraint name.
        $Unique
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
    if ($PSCmdlet.ParameterSetName -eq "UQ")
    {
        $op = New-Object 'Rivet.ConstraintName' $SchemaName, $TableName, $ColumnName, Unique
        $name = $op.Name
    }

    return $name
}