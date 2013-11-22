function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'VerboseSwitch' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-VerboseSwitch
{

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

'@ | New-Migration -Name 'VerboseSwitch'

    Invoke-Rivet -Push 'VerboseSwitch' -verbose




}