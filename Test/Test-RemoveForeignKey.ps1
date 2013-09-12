
function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RemoveForeignKey' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldRemoveForeignKey
{
    Invoke-Rivet -Push "RemoveForeignKey"
    Assert-ForeignKey -TableName 'Source' -References 'Reference' -TestRemoval
}