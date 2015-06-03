
function Get-Schema
{
    param(
        [string]
        # The name of the schema.  Optional.  Returns all schemas otherwise.
        $Name,

        $DatabaseName
    )
    
    Set-StrictMode -Version Latest

    $query = @'
        select 
            *,
            p.name principal_name
        from 
            sys.schemas s inner join 
            sys.database_principals p on s.principal_id = p.principal_id
'@
    if( $Name )
    {
         $query = '{0} where s.name = ''{1}''' -f $query,$Name
    }
    

    Invoke-RivetTestQuery -Query $query -DatabaseName $DatabaseName
}
