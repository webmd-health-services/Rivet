function New-StoredProcedure
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the stored procedure.
        $Name,
            
        [Parameter()]
        [string]
        # The schema name of the stored procedure.  Defaults to `dbo`.
        $SchemaName = 'dbo',
            
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The store procedure's definition.
        $Definition
    )
        
    $op = New-Object 'Rivet.Operations.NewStoredProcedureOperation' $SchemaName, $Name, $Definition
    Write-Host(' +[{0}].[{1}]' -f $SchemaName,$Name)
    Invoke-MigrationOperation -operation $op
}