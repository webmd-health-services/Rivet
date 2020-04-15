
function Remove-Index
{
    <#
    .SYNOPSIS
    Removes an index from a table.

    .DESCRIPTION
    The `Remove-Index` operation removes an index from a table.

    .EXAMPLE
    Remove-Index 'Cars' -Name 'YearIX'

    Demonstrates how to drop an index
    #>
    [CmdletBinding(DefaultParameterSetName='ByDefaultName')]
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
        [string[]]
        # OBSOLETE. Use the `Name` parameter to remove an index.
        $ColumnName,

        [Parameter(ParameterSetName='ByDefaultName')]
        [Switch]
        # OBSOLETE. Use the `Name` parameter to remove an index.
        $Unique,

        [Parameter(Mandatory=$true,ParameterSetName='ByExplicitName')]
        [string]
        # The name of the index to remove.
        $Name
    )

    Set-StrictMode -Version 'Latest'

    if( $PSCmdlet.ParameterSetName -eq "ByDefaultName" )
    {
        Write-Warning ('Remove-Index''s ColumnName parameter and Unique switch are obsolete and will be removed in a future version of Rivet. Instead, use the Name parameter to remove an index.')
        $Name = New-ConstraintName -Index -SchemaName $SchemaName -TableName $TableName -ColumnName $ColumnName -Unique:$Unique
    }

    [Rivet.Operations.RemoveIndexOperation]::new($SchemaName, $TableName, $Name)
}
