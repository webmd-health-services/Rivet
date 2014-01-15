
function Complete-MigrationOperation
{
    param(
        [Parameter(Mandatory=$true)]
        [Rivet.Operations.Operation]
        # The operation which was just applied.
        $Operation
    )

    if( $Operation -isnot [Rivet.Operations.AddTableOperation] )
    {
        return
    }

    $hasRowGuidCol = $Operation.Columns | 
                    Where-Object { $_.DataType -eq [Rivet.DataType]::UniqueIdentifier } |
                    Where-Object { $_.RowGuidCol } |
                    Where-Object { $_.Name -eq 'rowguid' }
    if( $hasRowGuidCol )
    {
        Add-Index -ColumnName 'rowguid' -Unique -SchemaName $Operation.SchemaName -TableName $Operation.Name
    }

    $trigger = @'
ON [{0}].[{1}]
FOR INSERT, UPDATE
NOT FOR REPLICATION
AS
IF @@ROWCOUNT = 0
    RETURN

--<< SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
SET NOCOUNT ON

--<< Update LastUpdated and SkipBit column on existing record
--<< To bypass the execution of this trigger set SkipBit = 1
IF ( (TRIGGER_NESTLEVEL(@@PROCID) = 1 AND (NOT UPDATE(SkipBit) OR EXISTS(select SkipBit from Inserted where isnull(SkipBit, 0) = 0))) )
BEGIN
    UPDATE t1
    SET
        LastUpdated = GETDATE(),
        SkipBit     = 0
    FROM [{0}].[{1}] t1
    INNER JOIN Inserted ON t1.rowguidcol = Inserted.rowguidcol
END
'@ -f $Operation.SchemaName,$Operation.Name

    Add-Trigger ('tr{0}_Activity' -f $Operation.Name) -Definition $trigger
}
