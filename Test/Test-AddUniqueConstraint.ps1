function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddUniqueConstraint' 
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

function Test-ShouldAddUniqueConstraintToOneColumn
{
    Invoke-Rivet -Push 'AddUniqueConstraintToOneColumn'
    Assert-UniqueConstraint -TableName 'AddUniqueConstraint' -ColumnName 'UniqueConstraintMe'
}

function Test-ShouldAddUniqueConstraintToMultipleColumns
{
    Invoke-Rivet -Push 'AddUniqueConstraintToMultipleColumns'
    Assert-UniqueConstraint -TableName 'AddUniqueConstraint' -ColumnName 'UniqueConstraintMe','UniqueConstraintMe2'
}

function Test-ShouldAddUniqueConstraintWithClustered
{
    Invoke-Rivet -Push 'AddUniqueConstraintWithClustered'
    Assert-UniqueConstraint -TableName 'AddUniqueConstraint' -ColumnName 'UniqueConstraintMe','UniqueConstraintMe2' -TestClustered
}

function Test-ShouldAddUniqueConstraintWithFillFactor
{
    Invoke-Rivet -Push 'AddUniqueConstraintWithFillFactor'
    Assert-UniqueConstraint -TableName 'AddUniqueConstraint' -ColumnName 'UniqueConstraintMe','UniqueConstraintMe2' -TestFillFactor 80
}

function Test-ShouldAddUniqueConstraintWithOptions
{
    Invoke-Rivet -Push 'AddUniqueConstraintWithOptions'
    Assert-UniqueConstraint -TableName 'AddUniqueConstraint' -ColumnName 'UniqueConstraintMe','UniqueConstraintMe2' -TestOption
}

function Test-ShouldAddUniqueConstraintWithCustomFileGroup
{
    $Error.Clear()
    Invoke-Rivet -Push 'AddUniqueConstraintWithCustomFileGroup' -ErrorAction SilentlyContinue
    Assert-True (0 -lt $Error.Count)
    Assert-Like $Error[1].Exception.Message '*Invalid filegroup*'
}