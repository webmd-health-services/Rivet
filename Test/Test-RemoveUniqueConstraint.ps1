function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RemoveUniqueConstraint' 
    Start-RivetTest

    # yes, on PowerShell 2 these tests need a breather.  Not sure why.
    if( $PSVersionTable.PsVersion -eq '2.0' )
    {
        Start-Sleep -Milliseconds 200
    }
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldRemoveUniqueConstraint
{
    Invoke-Rivet -Push 'RemoveUniqueConstraint'
    Assert-UniqueConstraint -TableName 'RemoveUniqueConstraint' -ColumnName 'RemoveMyUniqueConstraint' -TestNoUnique

}