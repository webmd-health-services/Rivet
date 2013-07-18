
function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RemoveTable' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldRemoveTable
{
    Invoke-Rivet -Push 'AddTable'
    Assert-True (Test-Table 'Ducati')

    Invoke-Rivet -Pop ([Int32]::MaxValue)
    Assert-False (Test-Table 'Ducati')
}

function Test-ShouldRemoveTableInCustomSchema
{
    $Name = 'Ducati'
    $CustomSchemaName = 'notDbo'
    
    Invoke-Rivet -Push 'AddTablesInDifferentSchemas'
    Assert-True (Test-Table -Name $Name)
    Assert-True (Test-Table -Name $Name -SchemaName $CustomSchemaName)
    
    Invoke-Rivet -Pop ([Int32]::MaxValue)
    Assert-True (Test-Table -Name $Name)
    Assert-False (Test-Table -Name $Name -SchemaName $CustomSchemaName)
}
