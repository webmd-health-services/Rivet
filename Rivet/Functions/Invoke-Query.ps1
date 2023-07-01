
function Invoke-Query
{
    <#
    .SYNOPSIS
    Executes a SQL query against the database.

    .DESCRIPTION
    The `Invoke-Query` function runs arbitrary queries aginst the database. Queries are split on `GO` statements, and
    each query is sent individually to the database.

    By default, rows are returned as anonymous PsObjects, with properties for each named column returned. Unnamed
    columns are given arbitrary `ColumnIdx` names, where `Idx` is a number the increments by one for each anonymous
    column, beginning with 0.

    You can return the results as a scalar using the AsScalar parameter.

    use the `NonQuery` switch to run non-queryies (e.g. `update`, `insert`, etc.). In this case, the number of rows
    affected by the query is returned.

    Do not use this method to migrate/transform your database, or issue DDL queries! The queries issued by this function
    happen before the DDL applied by a migration's operations. Use the `Invoke-Ddl` function instead. If you need to
    dynamically migrate your database based on its state, use this function to query the state of the database, and the
    other Rivet operations to perform the migration.

    You can pipe queries to this method, too!

    .LINK
    Invoke-Ddl

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
        [Parameter(Mandatory)]
        [Rivet_Session] $Session,

        [Parameter(Mandatory, Position=0, ValueFromPipeline)]
        [String] $Query,

        [Parameter()]
        [hashtable] $Parameter,

        [Parameter(Mandatory, ParameterSetName='ExecuteScalar')]
        [switch] $AsScalar,

        [Parameter(Mandatory, ParameterSetName='ExecuteNonQuery')]
        [switch] $NonQuery
    )

    process
    {
        Set-StrictMode -Version 'Latest'
        Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

        $conn = $Session.Connection
        $trx = $Session.CurrentTransaction
        $cmdTimeout = $Session.CommandTimeout

        $queries =  $Query | Split-SqlBatchQuery -Verbose:$false | Where-Object { $_ }
        foreach ($queryBatch in $queries)
        {
            $cmd = [Data.SqlClient.SqlCommand]::New($queryBatch, $conn, $trx)

            $cmdStartedAt = [DateTime]::UtcNow
            try
            {
                $cmd.CommandTimeout = $cmdTimeout

                if( $Parameter )
                {
                    foreach ($name in $Parameter.Keys)
                    {
                        $value = $Parameter[$name]
                        if( -not $name.StartsWith( '@' ) )
                        {
                            $name = '@{0}' -f $name
                        }
                        [void] $cmd.Parameters.AddWithValue( $name, $value )
                    }
                }

                if( $PSCmdlet.ParameterSetName -eq 'ExecuteNonQuery' )
                {
                    $cmd.ExecuteNonQuery()
                }
                elseif( $PSCmdlet.ParameterSetName -eq 'ExecuteScalar' )
                {
                    $cmd.ExecuteScalar()
                }
                else
                {
                    $cmdReader = $cmd.ExecuteReader()
                    try
                    {
                        if( $cmdReader.HasRows )
                        {
                            while( $cmdReader.Read() )
                            {
                                $row = @{ }
                                for ($i= 0; $i -lt $cmdReader.FieldCount; $i++)
                                {
                                    $name = $cmdReader.GetName( $i )
                                    if( -not $name )
                                    {
                                        $name = 'Column{0}' -f $i
                                    }
                                    $value = $cmdReader.GetValue($i)
                                    if( $cmdReader.IsDBNull($i) )
                                    {
                                        $value = $null
                                    }
                                    $row[$name] = $value
                                }
                                New-Object PsObject -Property $row
                            }
                        }
                    }
                    finally
                    {
                        $cmdReader.Close()
                    }
                }
            }
            finally
            {
                $queryLines = & {
                    if ($cmd.Parameters.Count)
                    {
                        $paramFieldLength =
                            $cmd.Parameters |
                            Select-Object -ExpandProperty 'ParameterName' |
                            Select-Object -ExpandProperty 'Length' |
                            Measure-Object -Maximum |
                            Select-Object -ExpandProperty 'Maximum'
                        for ($idx = 0 ; $idx -lt $cmd.Parameters.Count ; ++$idx)
                        {
                            $param = $cmd.Parameters[$idx]
                            $paramName = $param.ParameterName.PadRight($paramFieldLength)
                            $paramValue = $param.Value
                            "${paramName}  ${paramValue}" | Write-Output
                        }
                    }
                    $queryBatch -split ([regex]::Escape([Environment]::NewLine))
                }
                $cmd.Dispose()

                $firstLine = $queryLines | Select-Object -First 1
                $duration = [DateTime]::UtcNow - $cmdStartedAt
                $durationMsg = '{0,11:#,##0.000} (s)  ' -f $duration.TotalSeconds
                Write-Verbose -Message "${durationMsg}${firstLine}"
                $indent = ' ' * $durationMsg.Length
                $queryLines | Select-Object -Skip 1 | ForEach-Object { Write-Verbose -Message "${indent}${_}" }
            }
        }
    }
}
