function Update-Row
{
    <#
    .SYNOPSIS
    Updates a row of data in a table.
    
    .DESCRIPTION
    To specify which columns in a row to update, pass a hashtable as a value to the `Column` parameter.  This hashtable should have keys that map to column names, and the value of each key will be used to update row(s) in the table.
    
    You are required to use a `Where` clause so that you don't inadvertently/accidentally update a column in every row in a table to the same value.  If you *do* want to update the value in every row of the database, omit the `Where` parameter and add the `Force` switch.
    
    .EXAMPLE
    Update-Row -SchemaName 'rivet' 'Migrations' @{ LastUpdated = (Get-Date -Utc) } -Where 'MigrationID=20130913131104'
    
    Demonstrates how to update the `LastUpdated` date in the `rivet.Migrations` table for the migration with ID `20130913131104`.  Don't do this in real life.
    
    .EXAMPLE
    Update-Row -SchemaName 'rivet' 'Migrations' @{ LastUpdated = (Get-Date -Utc) } -Force
    
    Demonstrates how to update the `LastUpdated` date *for all rows* in the `rivet.Migrations` table.  You *really, really* don't want to do this in real life.
    #>
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the table.
        $TableName,
        
        [Parameter()]
        [string]
        # The schema name of the table.  Default is `dbo`.
        $SchemaName = 'dbo',
        
        [Parameter(Mandatory=$true,Position=1)]
        [Hashtable]
        # A hashtable of name/value pairs that map to column names/values that will be updated.
        $Column,
        
        [Parameter(Mandatory=$true,Position=2,ParameterSetName='SpecificRows')]
        [string]
        # A condition to use so that only certain rows are updated.  Without a value, you will need to use the `Force` parameter so you don't accidentally update the contents of an entire table.
        $Where,
        
        [Parameter(Mandatory=$true,ParameterSetName='AllRows')]
        [Switch]
        # Updates all the rows in the table.
        $All
    )

    if ($PSCmdlet.ParameterSetName -eq 'SpecificRows')
    {
        $op = New-Object 'Rivet.Operations.UpdateRowOperation' $SchemaName, $TableName, $Column, $Where        
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'AllRows')
    {
        $op = New-Object 'Rivet.Operations.UpdateRowOperation' $SchemaName, $TableName, $Column
    }

    $rowsUpdated = Invoke-MigrationOperation –Operation $op -NonQuery
    Write-Host (" [{0}].[{1}] ={2} row(s)" -f $SchemaName, $TableName, $rowsUpdated)
}