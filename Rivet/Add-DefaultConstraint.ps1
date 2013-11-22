function Add-DefaultConstraint
{
    <#
    .SYNOPSIS
    Creates a Default constraint to an existing column

    .DESCRIPTION
    Creates a Default constraint to an existing column 
    The DEFAULT constraint is used to insert a default value into a column.  The default value will be added to all new records, if no other value is specified.
    
    .LINK
    Add-DefaultConstraint

    .EXAMPLE
    Add-DefaultConstraint -TableName Cars -ColumnName Year

    Adds an Default constraint on column 'Year' in the table 'Cars'

    .EXAMPLE 
    Add-DefaultConstraint -TableName 'Cars' -ColumnName 'Year' ##TODO###

    Adds an Default constraint on column 'Year' in the table 'Cars' with specified options

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

        [Parameter(Mandatory=$true,Position=1,ParameterSetName='ByDefaultName')]
        [string]
        # The column on which to add the default constraint
        $ColumnName,

        [Parameter(Mandatory=$true,ParameterSetName='ByCustomName')]
        [string]
        # The name for the <object type>. If not given, a sensible name will be created.
        $Name,

        [Parameter(Mandatory=$true,Position=2,ParameterSetName='ByDefaultName')]
        [Parameter(Mandatory=$true,Position=1,ParameterSetName='ByCustomName')]
        [string]
        #The default expression
        $Expression,

        [Parameter()]
        [switch]
        # WithValues
        $WithValues,

        [Switch]
        # Don't show any host output.
        $Quiet
    )

    Set-StrictMode -Version 'Latest'

    if ($PSBoundParameters.containskey("Name"))
    {
        $op = New-Object 'Rivet.Operations.AddDefaultConstraintOperation' $SchemaName, $TableName, $Expression, $ColumnName, $Name, $WithValues
    }
    else 
    {
        $op = New-Object 'Rivet.Operations.AddDefaultConstraintOperation' $SchemaName, $TableName, $Expression, $ColumnName, $WithValues
        $Name = $op.ConstraintName.Name
    }

    if( -not $Quiet )
    {
        Write-Host (' {0}.{1} +{2} {3} {4}' -f $SchemaName, $TableName, $Name, $ColumnName, $Expression)
    }
    Invoke-MigrationOperation -Operation $op
}
