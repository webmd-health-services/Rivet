
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-PastPresentFuture
{
    $createdAt = Invoke-RivetTestQuery -Query 'select getutcdate()' -AsScalar

    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        DateTime2 'id' -Precision 6
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateDateTime2Column'

    Invoke-RTRivet -Push 'CreateDateTime2Column'

    $migrationRow = Get-MigrationInfo -Name 'CreateDateTime2Column'

    Write-Verbose ("Time Variance: {0}" -f ($migrationRow.AtUTC - $createdAt))
    Write-Verbose "300 ms variance is allowed"
    Assert-True ($migrationRow.AtUTC.AddMilliseconds(300) -gt $createdAt) ($migrationRow.AtUTC - $createdAt)


}
