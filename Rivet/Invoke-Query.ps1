
filter Invoke-Query
{
    <#
    .SYNOPSIS
    Executes a SQL query against the database.
    
    .DESCRIPTION
    All migrations eventually come down to this method.  It takes raw SQL and executes it against the database.
    
    You can pipe parameter-less queries to this method, too!
    
    .EXAMPLE
    Invoke-Query -Query 'create table rivet.Migrations( )'
    
    Executes the create table syntax above against the database.
    
    .EXAMPLE
    Invoke-Query -Query 'select count(*) from MyTable' -Database MyOtherDatabase
    
    Executes a query against the non-current database.  Returns the rows as objects.
    
    .EXAMPLE
    'select count(*) from sys.tables' | Invoke-Query -AsScalar
    
    Demonstrates how queries can be piped into `Invoke-Query`.  Also shows how a result can be returned as a scalar.
    #>
    [CmdletBinding(DefaultParameterSetName='AsReader')]
    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [string]
        $Query,
        
        [Parameter(Mandatory=$true,ParameterSetName='ExecuteScalar')]
        [Switch]
        $AsScalar,
        
        [Parameter(Mandatory=$true,ParameterSetName='ExecuteNonQuery')]
        [Switch]
        $NonQuery,
        
        [UInt32]
        # The time in seconds to wait for the command to execute. The default is 30 seconds.
        $CommandTimeout = 30
    )

    $invokeMigrationParams = @{
                              }
    if( $PSBoundParameters.ContainsKey( 'AsScalar' ) )
    {
        $invokeMigrationParams.AsScalar = $true
    }
    
    if( $PSBoundParameters.ContainsKey( 'NonQuery' ) )
    {
        $invokeMigrationParams.NonQuery = $true
    }
    
    if( $PSBoundParameters.ContainsKey( 'CommandTimeout' ) )
    {
        $invokeMigrationParams.CommandTimeout = $CommandTimeout
    }

    $migration = New-MigrationObject -Property @{ Query = $Query } -ToQueryMethod { return $this.Query }
    Invoke-Migration -Migration $migration @invokeMigrationParams
}
