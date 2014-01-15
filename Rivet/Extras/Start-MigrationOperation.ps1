
function Start-MigrationOperation
{
    param(
        [Parameter(Mandatory=$true)]
        [Rivet.Operations.Operation]
        # The operation which is about to be applied.
        $Operation
    )

    if( -not ($Operation -is [Rivet.Operations.AddTableOperation]) )
    {
        return
    }

    Invoke-Command {
        smalldatetime 'CreateDate' -NotNull -Default 'getdate()' -Description 'Record created date'
        datetime 'LastUpdated' -NotNull -Default 'getdate()' -Description 'Date this record was last updated' 
    } | ForEach-Object { $Operation.Columns.Add( $_ ) }

    $skipRowGuidCol = $Operation.Columns | 
                        Where-Object { $_.DataType -eq [Rivet.DataType]::UniqueIdentifier } |
                        Where-Object { $_.RowGuidCol }
    if( -not $skipRowGuidCol )
    {
        $Operation.Columns.Add( 
            (uniqueidentifier 'rowguid' -NotNull -RowGuidCol -Default 'newsequentialid()' -Description 'rowguid column used for replication')
        )

    }

    $Operation.Columns.Add( (bit 'SkipBit' -Default 0 -Description 'Used to bypass custom triggers') )
}
