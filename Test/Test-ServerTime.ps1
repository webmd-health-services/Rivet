function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'ServerTime' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-PastPresentFuture
{

    $createdAt = (Get-Date).ToUniversalTime()

    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        DateTime2 'id' -Precision 6
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDateTime2Column'

    Invoke-Rivet -Push 'CreateDateTime2Column'

    $migrationRow = Get-MigrationInfo -Name 'CreateDateTime2Column'

    Write-Host ("Time Variance: {0}" -f ($migrationRow.AtUTC - $createdAt))
    Write-Host "300 ms variance is allowed"
    Assert-True ($migrationRow.AtUTC.AddMilliseconds(300) -gt $createdAt) ($migrationRow.AtUTC - $createdAt)


}