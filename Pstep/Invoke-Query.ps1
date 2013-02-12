
function Invoke-Query
{
    <#
    .SYNOPSIS
    Executes a SQL query against the database.
    
    .DESCRIPTION
    All migrations eventually come down to this method.  It takes raw SQL and executes it against the database.
    
    .EXAMPLE
    Invoke-Query -Query 'create table pstep.Migrations( )'
    
    Executes the create table syntax above against the database.
    
    .EXAMPLE
    Invoke-Query -Query 'select count(*) from MyTable' -Database MyOtherDatabase
    
    Executes a query against the non-current database.  Returns the rows as objects.
    #>
    [CmdletBinding()]
    param(
        $Query,
        
        $Database = $Database
    )
    
    Write-Verbose ('[{0}.{1}] {2}' -f $SqlServerName,$Database,$Query)
    Invoke-SqlCmd -ServerInstance $SqlServerName -Database $Database -Query $Query
}
