
function Assert-Table
{
    param(
        $Name,

        [string]
        $SchemaName = 'dbo',

        $Description,

        [int]
        $DataCompression
    )
    
    Set-StrictMode -Version Latest

    $table = Get-Table -Name $Name -SchemaName $SchemaName
    Assert-NotNull $table ('table {0} not found' -f $Name) 

    if( $PSBoundParameters.ContainsKey('Description') )
    {
        Assert-Equal $Description $table.MSDescription ('table {0} MS_Description extended property' -f $Name)
    }

    if( $PSBoundParameters.ContainsKey('DataCompression') )
    {
        Assert-Equal $DataCompression $table.data_compression ('table {0} data compression option not set' -f $Name)
    }
}
