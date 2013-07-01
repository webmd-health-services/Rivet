
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

function Test-ShouldRemoveTableInCustomSchema
{
    $Name = 'Ducati'
    $CustomSchemaName = 'notDbo'
    
    Invoke-Pstep -Push 'AddTablesInDifferentSchemas'
    Assert-True (Test-Table -Name $Name)
    Assert-True (Test-Table -Name $Name -SchemaName $CustomSchemaName)
    
    Invoke-Pstep -Pop ([Int32]::MaxValue)
    Assert-True (Test-Table -Name $Name)
    Assert-False (Test-Table -Name $Name -SchemaName $CustomSchemaName)
}
