function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddDefaultConstraint' 
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

function Test-ShouldAddDefaultConstraint
{
    Invoke-Rivet -Push 'AddDefaultConstraint'
    Assert-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe'

}

function Test-ShouldAddDefaultConstraintWithValues
{
    $Error.Clear()
    Invoke-Rivet -Push 'AddDefaultConstraintWithValues'
    Assert-DefaultConstraint -TableName 'AddDefaultConstraint' -ColumnName 'DefaultConstraintMe'
    Assert-Equal 0 $Error.Count
}