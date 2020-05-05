function Add-DefaultConstraint
{
    <#
    .SYNOPSIS
    Creates a Default constraint to an existing column

    .DESCRIPTION
    The DEFAULT constraint is used to insert a default value into a column.  The default value will be added to all new records, if no other value is specified.
    
    .LINK
    Add-DefaultConstraint

    .EXAMPLE
    Add-DefaultConstraint -TableName Cars -ColumnName Year -Expression '2015'

    Adds an Default constraint on column 'Year' in the table 'Cars'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,Position=0)]
        # The name of the target table.
        [String]$TableName,

        # The schema name of the target table.  Defaults to `dbo`.
        [String]$SchemaName = 'dbo',

        [Parameter(Mandatory,Position=1)]
        # The column on which to add the default constraint
        [String]$ColumnName,

        # The name for the default constraint.
        [String]$Name,

        [Parameter(Mandatory,Position=2)]
        #The default expression
        [String]$Expression,

        # WithValues
        [switch]$WithValues
    )

    Set-StrictMode -Version 'Latest'

    [Rivet.Operations.AddDefaultConstraintOperation]::new($SchemaName, $TableName, $Name, $ColumnName, $Expression, $WithValues)
}
