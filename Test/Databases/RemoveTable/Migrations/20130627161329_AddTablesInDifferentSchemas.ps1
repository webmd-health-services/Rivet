function Push-Migration()
{
    Add-Table -Name 'Ducati' {
        New-Column 'ID' -Int -Identity 
    }
    Invoke-Query 'create schema notDbo'
    Add-Table -Name 'Ducati' {
        New-Column 'ID' -Int -Identity 
    } -SchemaName 'notDbo'
}

function Pop-Migration()
{
    Remove-Table -Name 'Ducati' -SchemaName 'notDbo'
}
