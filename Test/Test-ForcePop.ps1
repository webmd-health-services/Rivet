function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'ForcePop' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ForcePop
{

    @'
function Push-Migration
{
    Add-Table -Name 'Foobar1' -Column {
        DateTime2 'id' -Precision 6
    } -Option 'data_compression = none'

}

function Pop-Migration
{
    Remove-Table -Name 'Foobar1'
}

'@ | New-Migration -Name 'A'

Start-Sleep -Seconds 1

    @'
function Push-Migration
{
    Add-Table -Name 'Foobar2' -Column {
        DateTime2 'id' -Precision 6
    } -Option 'data_compression = none'


}

function Pop-Migration
{
    Remove-Table -Name 'Foobar2'
}

'@ | New-Migration -Name 'B'

    Invoke-Rivet -Push 'A'
    Invoke-Rivet -Push 'B'
    
    Invoke-Rivet -Force
    
    Assert-False (Test-Table 'Foobar1')
    Assert-False (Test-Table 'Foobar2')
}