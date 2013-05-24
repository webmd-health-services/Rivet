
function Remove-PstepTestDatabase
{
    $query = @'
    if( exists( select name from sys.databases where Name = '{0}' ) )
    begin
        ALTER DATABASE [{0}] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE

        DROP DATABASE [{0}]
    end
'@ -f $DatabaseName

    Invoke-PstepTestQuery -Query $query -Connection $MasterConnection

}
