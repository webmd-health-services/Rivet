
function Get-ForeignKeyColumns
{
    <#
    .SYNOPSIS
    Contains a row for each column, or set of columns, that comprise a foreign key.
    #>

    param(
        
    )
    
    Set-StrictMode -Version Latest

    $query = @'
    select * 
    from sys.foreign_key_columns
'@
    Invoke-RivetTestQuery -Query $query

}