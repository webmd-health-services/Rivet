
function Export-Row
{
    <#
    .SYNOPSIS
    Export rows from a database as a migration where those rows get added using the `Add-Row` operation.

    .DESCRIPTION
    When getting your database working with Rivet, you may want to get some data exported into an initial migration.
    This script does that.

    .EXAMPLE
    Export-Row -SqlServerName .\Rivet -DatabaseName 'Rivet' -SchemaName 'rivet' -TableName 'Migrations' -Column 'MigrationID','RunAtUtc'

    Demonstrates how to export the `MigrationID` and `RunAtUtc` columns of the `rivet.Migrations` table from the
    `.\Rivet.Rivet` database
    #>
    [CmdletBinding()]
    param(
        # The SQL Server to connect to.
        [Parameter(Mandatory=$true)]
        [String] $SqlServerName,

        # The name of the database.
        [Parameter(Mandatory=$true)]
        [String] $DatabaseName,

        # The schema of the table.
        [String] $SchemaName = 'dbo',

        # The name of the table.
        [Parameter(Mandatory=$true)]
        [String] $TableName,

        # The columns to export.
        [String[]] $Column,

        # An orderBy clause to use to order the results.
        [String] $OrderBy
    )

    #Require -Version 3
    Set-StrictMode -Version Latest

    $connectionString = 'Server={0};Database={1};Integrated Security=True;' -f $SqlServerName,$DatabaseName

    $connection = New-Object Data.SqlClient.SqlConnection $connectionString
    $columnClause = $Column -join ', '
    $query = 'select {0} from {1}.{2}' -f $columnClause,$SchemaName,$TableName
    if( $OrderBy )
    {
        $query += ' order by {0}' -f $OrderBy
    }
    $cmd = New-Object Data.SqlClient.SqlCommand ($query,$connection)

    $connection.Open()
    try
    {
        '    Add-Row -SchemaName ''{0}'' -TableName ''{1}'' -Column @('
        $cmdReader = $cmd.ExecuteReader()
        try
        {
            if( -not $cmdReader.HasRows )
            {
                return
            }

            while( $cmdReader.Read() )
            {
                '        @{'
                for ($i= 0; $i -lt $cmdReader.FieldCount; $i++)
                {
                    if( $cmdReader.IsDbNull( $i ) )
                    {
                        continue
                    }
                    $name = $cmdReader.GetName( $i )
                    $value = $cmdReader.GetValue($i)
                    if( $value -is [Boolean] )
                    {
                        $value = if( $cmdReader.GetBoolean($i) ) { '1' } else { '0' }
                    }
                    elseif( $value -is [string] )
                    {
                        $value = "'{0}'" -f $value.ToString().Replace("'","''")
                    }
                    elseif( $value -is [DAteTime] -or $value -is [Guid] )
                    {
                        $value = "'{0}'" -f $value
                    }
                    else
                    {
                        $value = $value.ToString()
                    }

                    '            {0} = {1};' -f $name,$value
                }
                '        },'
            }
        }
        finally
        {
            '    )'
            $cmdReader.Close()
        }
    }
    finally
    {
        $cmd.Dispose()
        $connection.Close()
    }
}
