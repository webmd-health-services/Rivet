
function Assert-UniqueKey
{
    <#
    .SYNOPSIS
    Tests that a unique Key exists for a particular column and table.
    #>
    [CmdletBinding(DefaultParameterSetName='ByDefaultName')]
    param(
        [Parameter(ParameterSetName='ByDefaultName')]
        # The table's schema.  Default is `dbo`.
        [String]$SchemaName = 'dbo',

        [Parameter(Mandatory,ParameterSetName='ByDefaultName')]
        # The name of the table
        [String]$TableName,

        [Parameter(Mandatory,ParameterSetName='ByCustomName')]
        [String]$Name,

        # Array of Column Names
        [String[]]$ColumnName,

        # Index Created Should be Clustered
        [switch]$Clustered,

        # Index Created Should have a Fill Factor
        [int]$FillFactor,

        [switch]$IgnoreDupKey,

        [switch]$DenyRowLocks
    )

    Set-StrictMode -Version Latest

    if( -not $Name )
    {
        $Name = New-RTConstraintName -SchemaName $SchemaName -TableName $TableName -ColumnName $ColumnName -UniqueKey
    }
    $key = Get-UniqueKey -Name $Name

    $key | Should -Not -BeNullOrEmpty ('Unique key on {0}.{1}.{2} not found.' -f $SchemaName,$TableName,($ColumnName -join ','))

    if( $Clustered )
    {
        $key.type_desc | Should -Be "CLUSTERED"
        $key.type | Should -Be 1
    }
    else
    {
        $key.type_desc | Should -Be "NONCLUSTERED"
        $key.type | Should -Be 2
    }

    if( $PSBoundParameters.ContainsKey('FillFactor') )
    {
        $key.fill_factor | Should -Be $FillFactor
    }

    $key.ignore_dup_key | Should -Be $IgnoreDupKey -Because ('key {0} ignore_dup_key' -f $key.name)
    $key.allow_row_locks | Should -Be (-not $DenyRowLocks) -Because ('key {0} allow_row_locks' -f $key.name)

    $key.Columns.Length | Should -Be $ColumnName.Length
    for( $idx = 0; $idx -lt $ColumnName.Length; ++$idx )
    {
        $key.Columns[$idx].column_name | Should -Be $ColumnName[$idx]
    }
}
