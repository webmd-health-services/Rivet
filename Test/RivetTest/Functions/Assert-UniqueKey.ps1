
function Assert-UniqueKey
{
    <#
    .SYNOPSIS
    Tests that a unique Key exists for a particular column and table.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        # The table's schema.  Default is `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table
        $TableName,

        [string[]]
        # Array of Column Names
        $ColumnName,

        [Switch]
        # Index Created Should be Clustered
        $Clustered,

        [Int]
        # Index Created Should have a Fill Factor
        $FillFactor,

        [Switch]
        $IgnoreDupKey,

        [Switch]
        $DenyRowLocks
    )
    
    Set-StrictMode -Version Latest

    $key = Get-UniqueKey -SchemaName $SchemaName -TableName $TableName -ColumnName $ColumnName

    if( (Test-Pester) )
    {
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
    else
    {
        Assert-NotNull $key ('Unique key on {0}.{1}.{2} not found.' -f $SchemaName,$TableName,($ColumnName -join ','))

        if( $Clustered )
        {
            Assert-Equal "CLUSTERED" $key.type_desc 
            Assert-Equal 1 $key.type
        }
        else
        {
            Assert-Equal "NONCLUSTERED" $key.type_desc
            Assert-Equal 2 $key.type
        }

        if( $PSBoundParameters.ContainsKey('FillFactor') )
        {
            Assert-Equal $FillFactor $key.fill_factor
        }

        Assert-Equal $IgnoreDupKey $key.ignore_dup_key ('key {0} ignore_dup_key' -f $key.name)
        Assert-Equal (-not $DenyRowLocks) $key.allow_row_locks ('key {0} allow_row_locks' -f $key.name)

        Assert-Equal $ColumnName.Length $key.Columns.Length
        for( $idx = 0; $idx -lt $ColumnName.Length; ++$idx )
        {
            Assert-Equal $ColumnName[$idx] $key.Columns[$idx].column_name 
        }
    }
}
