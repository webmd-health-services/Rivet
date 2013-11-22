function Complete-AddTable
{
    param(

            [string]
            $TableName,

            [string]
            $SchemaName
        )

    Update-Table -SchemaName $SchemaName -Name $TableName -AddColumn {
        SmallDateTime 'CreateDate' -NotNull
        DateTime 'LastUpdated' -NotNull
        UniqueIdentifier 'RowGuid' -RowGuidCol -NotNull
        Bit 'SkipBit'
    }

    Write-Host ("+ Admin Columns for {0}.{1}" -f $SchemaName, $TableName)
}