
function Setup
{
    Import-Module -Name (Join-Path $TestDir 'PstepTest') -ArgumentList 'RemoveTable' 
    Start-PstepTest
}

function TearDown
{
    Stop-PstepTest
    Remove-Module PstepTest
}

function Test-ShouldRemoveTable
{
    Invoke-Pstep -Push 'AddTable'
    Assert-True (Test-Table 'Ducati')

    Invoke-Pstep -Pop ([Int32]::MaxValue)
    Assert-False (Test-Table 'Ducati')
}

function Test-ShouldRemoveTableInCorrectSchema
{
    # Create migration to add table with same name in two schemas
    # .\Pstep\pstep.ps1 -New -Name AddTable -Database RemoveTable -Path .\Test\Databases\RemoveTable
    # .\Pstep\pstep.ps1 -New -Name RemoveTableInCustomSchema -Database RemoveTable -Path .\Test\Databases\RemoveTable
    # Test tables exist
    # Create migration to remove table in custom schema
    # Test dbo table exists
    # Test custom schema table does not exist.
}
