function Add-Row
{
    <#
    .SYNOPSIS
    Inserts a row of data in a table.
    
    .DESCRIPTION
    To specify which columns to insert into the new row, pass a hashtable as a value to the `Column` parameter.  This hashtable should have keys that map to column names, and the value of each key will be used as the value for that column in the row.
    
    .EXAMPLE
    Add-Row -SchemaName 'rivet' 'Migrations' @{ ID = 2013093131104 ; Name = 'AMadeUpMigrationDoNotDoThis' ; Who = 'abadbadman' ; ComputerName 'abadbadcomputer' }
    
    Demonstrates how to insert a row into the `rivet.Migrations` table.  This is for illustrative purposes only.  If you do this yourself, a butterfly loses its wings.
    
    .EXAMPLE
    Add-Row 'Cars' @( @{ Make = 'Toyota' ; Model = 'Celica' }, @{ Make = 'Toyota' ; Model = 'Camry' } )
    
    Demonstrates how to insert multiple rows into a table by passing an array of hashtables.
    
    .EXAMPLE
    @( @{ Make = 'Toyota' ; Model = 'Celica' }, @{ Make = 'Toyota' ; Model = 'Camry' } ) | New-Row 'Cars' 
    
    Demonstrates how to pipe data into `New-Row` to insert a bunch of rows into the database.
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
        
        [Parameter(Mandatory=$true,Position=1,ValueFromPipeline=$true)]
        [Hashtable[]]
        # A hashtable of name/value pairs that map to column names/values that will inserted.
        $Column,

        [Switch]
        # Allow inserting identies.
        $IdentityInsert
    )

    process
    {
        $op = New-Object 'Rivet.Operations.AddRowOperation' $SchemaName, $TableName, $Column, $IdentityInsert
        Write-Host (" {0}.{1} +" -f $SchemaName,$TableName) -NoNewline
        $rowsAdded = Invoke-MigrationOperation -operation $op -NonQuery
        Write-Host ("{0} row(s)" -f $rowsAdded)
    }
}