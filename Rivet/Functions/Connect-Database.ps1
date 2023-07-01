
function Connect-Database
{
    param(
        [Parameter(Mandatory)]
        [Rivet_Session] $Session,

        [String] $Name
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    if (-not $Name)
    {
        if ($Session.Databases.Count -eq 0)
        {
            $msg = 'Unable to connect to database because the current Rivet session has no databases.'
            Write-Error -Message $msg
            return
        }

        if ($Session.Databases.Count -gt 1)
        {
            $msg = 'Unable to connect to database because the current Rivet session has multiple databases and we ' +
                   'don''t know which one to connect to. Please pass a database name to the `Connect-Database` ' +
                   'function''s `Name` parameter.'
            Write-Error -Message $msg
            return
        }

        $Name = $Session.Databases[0].Name
    }

    $startedAt = Get-Date

    $connection = $Session.Connection
    $sqlServerName = $Session.SqlServerName
    $connTimeout = $Session.ConnectionTimeout

    if (-not $connection -or `
        $connection.DataSource -ne $sqlServerName -or `
        $connection.State -eq [Data.ConnectionState]::Closed)
    {
        Disconnect-Database -Session $Session

        $connString =
            "Server=${sqlServerName};Integrated Security=True;Connection Timeout=${connTimeout}"
        $Session.Connection = $connection = [Data.SqlClient.SqlConnection]::New($connString)

        $connection.Open()
        Write-Verbose -Message "[$($connection.DataSource)].[$($connection.Database)]"
    }

    try
    {
        # We're already connected to the database.
        if ($connection.Database -eq $Name)
        {
            return
        }

        $query = "select 1 from sys.databases where name='${Name}'"
        $dbExists = Invoke-Query -Session $Session -Query $query -AsScalar
        if (-not $dbExists)
        {
            Write-Debug -Message ('Creating database {0}.{1}.' -f $SqlServerName,$Name)
            $query = "create database [${Name}]"
            Invoke-Query -Session $Session -Query $query -NonQuery | Out-Null
        }

        $connection.ChangeDatabase($Name)
        Write-Verbose -Message "[$($connection.DataSource)].[$($connection.Database)]"
        $Session.CurrentDatabase = $Session.Databases | Where-Object 'Name' -EQ $Name
    }
    finally
    {
        Write-Debug -Message ('{0,8} (ms)   Connect-Database' -f ([int]((Get-Date) - $startedAt).TotalMilliseconds))
    }
}