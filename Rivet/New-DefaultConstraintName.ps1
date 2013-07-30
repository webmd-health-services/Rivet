
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

        [Parameter(Mandatory=$true,ParameterSetName='FK')]
        [Switch]
        # Creates a foreign key name.
        $ForeignKey,

        [Parameter(Mandatory=$true,ParameterSetName='IX')]
        [Switch]
        # Creates an index name.
        $Index,

        [Parameter(Mandatory=$true,ParameterSetName='UQ')]
        [Switch]
        # Creates an 'unique' constraint name.
        $Unique
    )

    $columns = $ColumnName -join '_'
    $name = '{0}_{1}_{2}_{3}' -f $PSCmdlet.ParameterSetName,$SchemaName,$TableName,$columns
    if( $SchemaName -eq 'dbo' )
    {
        $name = '{0}_{1}_{2}' -f $PSCmdlet.ParameterSetName,$TableName,$columns
    }
    return $name
}

Set-Alias -Name 'New-DefaultConstraintName' -Value 'New-ConstraintName'
