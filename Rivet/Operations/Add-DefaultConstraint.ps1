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
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the target table.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the target table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The column on which to add the default constraint
        $ColumnName,

        [string]
        # The name for the <object type>. If not given, a sensible name will be created.
        $Name,

        [Parameter(Mandatory=$true,Position=2)]
        [string]
        #The default expression
        $Expression,

        [Switch]
        # WithValues
        $WithValues
    )

    Set-StrictMode -Version 'Latest'

    if ($PSBoundParameters.containskey("Name"))
    {
        New-Object 'Rivet.Operations.AddDefaultConstraintOperation' $SchemaName, $TableName, $Expression, $ColumnName, $Name, $WithValues
    }
    else 
    {
        New-Object 'Rivet.Operations.AddDefaultConstraintOperation' $SchemaName, $TableName, $Expression, $ColumnName, $WithValues
    }

}
