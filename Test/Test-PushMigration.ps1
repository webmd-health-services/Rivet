
. (Join-Path $TestDir Initialize-PstepTest.ps1 -Resolve)

$connection = $null

function Setup
{
    New-Database

    $connection = Connect-Database
}

function TearDown
{
    Disconnect-Database -Connection $connection
    
    Remove-Database
}

function Test-ShouldPushMigrations
{
    $createdAt = (Get-Date).ToUniversalTime()
    & $pstep -Push -SqlServerName $server -Database $database -Path $dbsRoot
    
    Get-ChildItem (Join-Path $dbsRoot "$database\Migrations\*.ps1") | ForEach-Object {
        
        $id,$name = $_.BaseName -split '_'
        
        $query = 'select count(*) from sys.tables where name = ''{0}''' -f $name
        $tableCount = Invoke-Query -Query $query -Connection $connection -AsScalar
        Assert-Equal 1 $tableCount 'migration not run'
        
        $query = 'select * from pstep.Migrations where name = ''{0}''' -f $name
        $migrationRow = Invoke-Query -Query $query -Connection $connection
        Assert-IsNotNull $migrationRow
        Assert-False ($migrationRow -is [object[]])
        Assert-Equal $id $migrationRow.ID
        Assert-Equal $name $migrationRow.Name
        Assert-Equal ('{0}\{1}' -f $env:USERDOMAIN,$env:USERNAME) $migrationRow.Who
        Assert-Equal $env:ComputerName $migrationRow.ComputerName
        Assert-True ($migrationRow.AtUtc -gt $createdAt)
    }
    
    # Make sure they are run in order.
    $query = 'select name from pstep.Migrations order by AtUtc'
    $rows = Invoke-Query -Query $query -Connection $connection
    Assert-NotNull $rows
    Assert-Equal 'InvokeQuery' $rows[0].Name
    Assert-Equal 'SecondTable' $rows[1].Name
}