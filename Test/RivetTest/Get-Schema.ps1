
function Get-Schema
{
    param(
        [string]
        # The name of the schema.  Optional.  Returns all schemas otherwise.
        $Name
    )

    $query = 'select * from sys.schemas'
    if( $Name )
    {
         $query = '{0} where name = ''{1}''' -f $query,$Name
    }

    Invoke-PstepTestQuery -Query $query -Connection $DatabaseConnection
}