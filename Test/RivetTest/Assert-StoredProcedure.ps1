
function Assert-StoredProcedure
{
    <#
    .SYNOPSIS
    Tests that a stored procedure exists.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the stored procedure.
        $Name,

        [Parameter()]
        [string]
        # The schema name of the stored procedure.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [string]
        # The stored procedure's definition
        $Definition
    )
    
    Set-StrictMode -Version Latest

    $sp = Get-SysObjects | where{$_.type_desc -match "SQL_STORED_PROCEDURE" -and $_.name -match $Name}
   
    Assert-NotNull $sp ('Stored Procedure {0}.{1} doesn''t exist.' -f $SchemaName,$Name)

    if( $PSBoundParameters.ContainsKey('Definition') )
    {    
        $od = Get-ObjectDefinition $sp.object_id
        $expectedDefinition = "create procedure [{0}].[{1}] {2}" -f $SchemaName, $Name, $Definition
        Assert-Equal $expectedDefinition $od.'Object Definition'
    }

}