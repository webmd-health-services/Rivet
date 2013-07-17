
function New-SqlConnection
{
    <#
    .SYNOPSIS
    Creates a new database connection.

    .DESCRIPTION
    Don't forget to close it when you're done!
    #>
    param(
        [string]
        # The name of the database.
        $Database = $DatabaseName
    )

    $connString = 'Server={0};Database={1};Integrated Security=True;' -f $Server,$Database
    $connection = New-Object Data.SqlClient.SqlConnection ($connString)
    $connection.Open()
    return $connection
}