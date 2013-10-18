function Complete-AddTable
{
    param(

            [string]
            $TableName,

            [string]
            $SchemaName
        )

    Add-Column CreateDate -SmallDateTime -NotNull -TableName $TableName -SchemaName $SchemaName
    Add-Column LastUpdated -DataType datetime -NotNull -TableName $TableName -SchemaName $SchemaName
    Add-Column RowGuid -UniqueIdentifier -NotNull -RowGuidCol -TableName $TableName -SchemaName $SchemaName
    Add-Column SkipBit -Bit -TableName $TableName -SchemaName $SchemaName

    Write-Host ("+ Admin Columns for {0}.{1}" -f $SchemaName, $TableName)
}