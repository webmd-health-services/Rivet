
function New-RTConstraintName
{
    <#
    .SYNOPSIS
    Creates a default constraint name for a column in a table.
    #>
    [CmdletBinding(DefaultParameterSetName='DF')]
    param(
        [Parameter(Mandatory,ParameterSetName='DF')]
        # Creates a default constraint name.
        [switch]$Default,

        [Parameter(Mandatory,ParameterSetName='PK')]
        # Creates a primary key name.
        [switch]$PrimaryKey,

        [Parameter(Mandatory,ParameterSetName='IX')]
        # Creates an index name.
        [switch]$Index,

        [Parameter(ParameterSetName='IX')]
        # For a unique index.
        [switch]$Unique,

        [Parameter(Mandatory,ParameterSetName='AK')]
        # Creates an unique key/alternate key constraint name.
        [switch]$UniqueKey,

        [Parameter(Mandatory,ParameterSetName='FK')]
        # Creates a foreign key constraint name.
        [switch]$ForeignKey,

        # The table's schema.  Default is `dbo`.
        [String]$SchemaName = 'dbo',

        [Parameter(Mandatory,Position=0)]
        # The table name.
        [String]$TableName,

        [Parameter(Mandatory,ParameterSetName='DF',Position=1)]
        [Parameter(Mandatory,ParameterSetName='IX',Position=1)]
        [Parameter(Mandatory,ParameterSetName='AK',Position=1)]
        [Parameter(Mandatory,ParameterSetName='UIX',Position=1)]
        # The column name.
        [String[]]$ColumnName,

        [Parameter(ParameterSetName='FK')]
        [String]$ReferencesSchemaName = 'dbo',

        [Parameter(Mandatory,ParameterSetName='FK',Position=1)]
        [String]$ReferencesTableName
    )

    Set-StrictMode -Version 'Latest'

    $Global:rtParameters = $PSBoundParameters
    try
    {
        InModuleScope -ModuleName 'Rivet' {
            New-ConstraintName @rtParameters
        }
    }
    finally
    {
        Remove-Variable -Name 'rtParameters' -Scope Global
    }
}

