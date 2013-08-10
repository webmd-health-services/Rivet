
function Remove-Table
{
    <#
    .SYNOPSIS
    Removes a table from a database.

    .DESCRIPTION
    You can't get any of the data back, so be careful.

    .EXAMPLE
    Remove-Table -Name 'Coffee'

    Removes the `Coffee` table from the database.
    #>
    param(
        # The name of the table where the column should be removed.
        [Parameter(Mandatory=$true)]
        [string]
        $Name,

        [string]
        # The schema of the table where the column should be added.  Default is `dbo`.
        $SchemaName = 'dbo'
    )

    Write-Host (' -{0}.{1}' -f $SchemaName,$Name)
    $query = 'drop table [{0}].[{1}]' -f $SchemaName,$Name
    
    $op = New-Object 'Rivet.Operations.RawQueryOperation' $query
    Invoke-MigrationOperation -Operation $op
}
