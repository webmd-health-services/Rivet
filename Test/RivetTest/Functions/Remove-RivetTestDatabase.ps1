
function Remove-RivetTestDatabase
{
    param(
        [string]
        # The name of the database to remove.
        $Name = $RTDatabaseName
    )
    
    Set-StrictMode -Version Latest
    
    $query = @'
    if( exists( select name from sys.databases where Name = '{0}' ) )
    begin
        ALTER DATABASE [{0}] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE

        DROP DATABASE [{0}]
    end
'@ -f $Name

    Invoke-RivetTestQuery -Query $query -Master

    while( (Test-Database -Name $Name) )
    {
        Write-Warning -Verbose "Waiting for $($Name) database to get dropped."
        Start-Sleep -Milliseconds 100
    }
}
