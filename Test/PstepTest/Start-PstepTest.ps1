
function Start-PstepTest
{
    $tempDir = New-TempDir
    $DatabasesRoot = Join-Path $tempDir (Split-Path -Leaf $DatabasesSourcePath)
    $DatabaseName = '{0}{1}' -f $DatabaseSourceName,(get-date).ToString('yyyyMMddHHmmss')

    Remove-PstepTestDatabase

    Copy-Item -Path $DatabasesSourcePath -Destination $tempDir -Recurse
    Rename-Item -Path (Join-Path $DatabasesRoot $DatabaseSourceName) -NewName $DatabaseName
    $DatabaseRoot = Join-Path $DatabasesRoot $DatabaseName
    
    $query = @'
    if( not exists( select name from sys.databases where Name = '{0}' ) )
    begin
        create database [{0}]
    end
'@ -f $DatabaseName
    $cmd = New-Object Data.SqlClient.SqlCommand ($query,$MasterConnection)
    $cmd.ExecuteNonQuery()
    
    $connString = 'Server={0};Database={1};Integrated Security=True;' -f $Server,$DatabaseName
    $DatabaseConnection = New-Object Data.SqlClient.SqlConnection ($connString)
    $DatabaseConnection.Open()
}
