function Push-Migration()
{
    Add-Table -Name 'Ducati' {
        Int 'ID' -Identity 
    }
    Invoke-Query 'create schema notDbo'
    Add-Table -Name 'Ducati' {
        Int 'ID' -Identity 
    } -SchemaName 'notDbo'
}

function Pop-Migration()
{
    Remove-Table -Name 'Ducati' -SchemaName 'notDbo'
}
