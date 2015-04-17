
filter Invoke-Query
{
    <#
    .SYNOPSIS
    Executes a SQL query against the database.
    
    .DESCRIPTION
    All migrations eventually come down to this method.  It takes raw SQL and executes it against the database.  Queries are split on `GO` statements, and each query is sent individually to the database.
    
    You can pipe queries to this method, too!
    
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
        
        [Parameter()]
        [Hashtable]
        $Parameter,

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

    Set-StrictMode -Version 'Latest'

    $invokeMigrationParams = @{ }

    if( $PSBoundParameters.ContainsKey( 'Parameter' ) )
    {
        $invokeMigrationParams.Parameter = $Parameter
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

    $Query |
        Split-SqlBatchQuery |
        Where-Object { $_ } |
        ForEach-Object {
            Write-Verbose $_
            $operation = New-Object 'Rivet.Operations.RawQueryOperation' $_
            Invoke-MigrationOperation -Operation $operation @invokeMigrationParams
        }

}
