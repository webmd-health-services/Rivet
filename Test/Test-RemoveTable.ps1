
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldRemoveTable
{
    @'
function Push-Migration()
{
    Add-Table -Name 'Ducati' {
        Int 'ID' -Identity 
    } # -SchemaName

}

function Pop-Migration()
{
    Remove-Table -Name 'Ducati'
}
'@ | New-Migration -Name 'AddTable'
    Invoke-RTRivet -Push 'AddTable'
    Assert-True (Test-Table 'Ducati')

    Invoke-RTRivet -Pop ([Int32]::MaxValue)
    Assert-False (Test-Table 'Ducati')
}

function Test-ShouldRemoveTableInCustomSchema
{
    $Name = 'Ducati'
    $CustomSchemaName = 'notDbo'
    
@'
function Push-Migration()
{
    Add-Table -Name 'Ducati' {
        Int 'ID' -Identity 
    }
    Add-Schema -Name 'notDbo'

    Add-Table -Name 'Ducati' {
        Int 'ID' -Identity 
    } -SchemaName 'notDbo'
}

function Pop-Migration()
{
    Remove-Table -Name 'Ducati' -SchemaName 'notDbo'
    Remove-Table 'Ducati'
    Remove-Schema 'notDbo'
}
'@ | New-Migration -Name 'AddTablesInDifferentSchemas'    

    Invoke-RTRivet -Push 'AddTablesInDifferentSchemas'

    Assert-True (Test-Table -Name $Name)
    Assert-True (Test-Table -Name $Name -SchemaName $CustomSchemaName)
    
    Invoke-RTRivet -Pop ([Int32]::MaxValue)
    Assert-False (Test-Table -Name $Name)
    Assert-False (Test-Table -Name $Name -SchemaName $CustomSchemaName)
}
