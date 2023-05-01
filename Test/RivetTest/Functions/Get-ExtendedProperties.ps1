function Get-ExtendedProperties
{
    <#
    .SYNOPSIS
    Returns a row for each extended property in the current database.
    #>

    param(

    )

    Set-StrictMode -Version Latest

    $query = @'
    select *
    from sys.extended_properties
'@
    Invoke-RivetTestQuery -Query $query

}
