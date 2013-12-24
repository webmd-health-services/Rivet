function Complete-AddTable
{
    param(
        [string]
        $TableName,

        [string]
        $SchemaName
    )

    Update-Table -SchemaName $SchemaName -Name $TableName -AddColumn {
        smalldatetime 'CreateDate' -NotNull -Default 'getdate()' -Description 'Record created date'
        datetime 'LastUpdated' -NotNull -Default 'getdate()' -Description 'Date this record was last updated' 
        uniqueidentifier 'rowguid' -NotNull -RowGuidCol -Default 'newsequentialid()' -Description 'rowguid column used for replication'
        bit 'SkipBit' -Default 0 -Description 'Used to bypass custom triggers'
    }
    Add-Index -ColumnName 'rowguid' -Unique -SchemaName $SchemaName -TableName $TableName

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
'@ -f $SchemaName,$TableName

    Add-Trigger ('tr{0}_Activity' -f $TableName) -Definition $trigger
}
