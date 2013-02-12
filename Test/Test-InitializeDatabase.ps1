
$server = '.\InternalTools'
$database = 'PstepTest{0}' -f ((get-date).ToString('yyyyMMddHHmmss'))

. (Join-Path $TestDir ..\Pstep\Invoke-Query.ps1)

function Setup
{
    Remove-Database
    Assert-False (_Test-Database -Name $Database)
}

function TearDown
{
    Remove-Database
    if( (Get-Module Pstep -ErrorAction SilentlyContinue) )
    {
        Remove-Module Pstep
    }
}

function Test-ShouldCreateDatabaseUponModuleImport
{
    
    & (Join-Path $TestDir ..\Pstep\Import-Pstep.ps1 -Resolve) -SqlServerName $server -Database $database
    
    Assert-True (_Test-Database)
    
    $query = 'select count(*) from sys.schemas where name = ''pstep'''
    $schemaCount = Invoke-Query -SqlServerName $server -Database $database -Query $query -Scalar
    Assert-Equal 1 $schemaCount
    
    $query = @'
        select count(*) from sys.tables t inner join sys.schemas s on t.schema_id=s.schema_id 
            where t.name = 'Migrations' and s.name = 'pstep'
'@
    $tableCount = Invoke-Query -SqlServerName $server -Database $database -Query $query -Scalar
    Assert-Equal 1 $tableCount
}

function Remove-Database
{
    $query = @'
    if( exists( select name from sys.databases where Name = '{0}' ) )
    begin
        ALTER DATABASE [{0}] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE

        DROP DATABASE [{0}]
    end
'@ -f $database

    Invoke-Query -SqlServerName $server -Database 'master' -Query $Query -Parameter @{ Name = $database } -NonQuery
    
}

function _Test-Database
{
    $query = @'
    select count(*) Count from sys.databases where Name = @Name
'@ -f $database

    $dbCount = Invoke-Query -SqlServerName $server -Database 'master' -Query $query -Parameter @{ 'Name' = $Database } -Scalar
    return ($dbCount -eq 1)
}