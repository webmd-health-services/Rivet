
function New-ConstraintName
{
    <#
    .SYNOPSIS
    Creates a default constraint name for a column in a table.
    #>
    [CmdletBinding(DefaultParameterSetName='DF')]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='DF')]
        [Parameter(Mandatory=$true,ParameterSetName='IX')]
        [Parameter(Mandatory=$true,ParameterSetName='AK')]
        [Parameter(Mandatory=$true,ParameterSetName='UIX')]
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

        [Parameter(Mandatory=$true,ParameterSetName='DF')]
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

        [Parameter(ParameterSetName='IX')]
        [Switch]
        # For a unique index.
        $Unique,

        [Parameter(Mandatory=$true,ParameterSetName='AK')]
        [Switch]
        # Creates an unique key/alternate key constraint name.
        $UniqueKey
    )

    if ($PSCmdlet.ParameterSetName -eq "DF")
    {
        $op = New-Object 'Rivet.ConstraintName' $SchemaName, $TableName, $ColumnName, Default
    }

    if ($PSCmdlet.ParameterSetName -eq "PK")
    {
        $op = New-Object 'Rivet.ConstraintName' $SchemaName, $TableName, $null, PrimaryKey
    }
    
    if ($PSCmdlet.ParameterSetName -eq "IX")
    {
        $op = New-Object 'Rivet.IndexName' $SchemaName, $TableName, $ColumnName, $Unique
    }

    if ($PSCmdlet.ParameterSetName -eq "AK")
    {
        $op = New-Object 'Rivet.ConstraintName' $SchemaName, $TableName, $ColumnName, UniqueKey
    }

    return $op.Name
}
