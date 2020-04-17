
function Repair-Operation
{
    [CmdletBinding()]
    [OutputType([Rivet.Operations.Operation])]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [Rivet.Operations.Operation]$Operation
    )

    begin
    {
        Set-StrictMode -Version 'Latest'
    }

    process
    {
        # Currently, the only repairs we need to make are against objects that have names, so if there isn't a name, return.
        $name = $Operation | Select-Object -ExpandProperty 'Name' -ErrorAction Ignore
        if( $name -or -not ($Operation | Get-Member 'Name') )
        {
            return $Operation
        }

        $schemaName = $Operation | Select-Object -ExpandProperty 'SchemaName' -ErrorAction Ignore
        $tableName = $Operation | Select-Object -ExpandProperty 'TableName' -ErrorAction Ignore
        $columnName = $Operation | Select-Object -ExpandProperty 'ColumnName' -ErrorAction Ignore
        $columnDesc = $columnName -join '", "'
        $pluralSuffix = ''
        if( ($columnName | Measure-Object).Count -gt 1 )
        {
            $pluralSuffix = 's'
        }

        $tableDesc = "[$($schemaName)].[$($tableName)]"

        $warningMsg = ''

        switch( $Operation.GetType().Name )
        {
            'AddDefaultConstraintOperation'
            {
                $name = New-ConstraintName -Default -SchemaName $schemaName -TableName $tableName -ColumnName $columnName
                $warningMsg = "Default constraint names will be required in a future version of Rivet. Please add a " +
                              """Name"" parameter (with a value of ""$($name)"") to the Add-DefaultConstraint " +
                              "operation for the $($tableDesc) table's ""$($columnDesc)"" column."
            }
            'AddForeignKeyOperation'
            {
                $name = New-ConstraintName -ForeignKey `
                                           -SchemaName $schemaName `
                                           -TableName $tableName `
                                           -ReferencesSchemaName $Operation.ReferencesSchemaName `
                                           -ReferencesTableName $Operation.ReferencesTableName
                $warningMsg = "Foreign key constraint names will be required in a future version of Rivet. Please " +
                              "add a ""Name"" parameter (with a value of ""$($name)"") to the Add-ForeignKey " +
                              "operation for the $($tableDesc) table's ""$($columnDesc)"" column$($pluralSuffix)."
            }
            'AddIndexOperation'
            {
                $name = New-ConstraintName -Index -SchemaName $schemaName -TableName $tableName -ColumnName $columnName -Unique:$Operation.Unique
                $warningMsg = "Index names will be required in a future version of Rivet. Please add a ""Name"" " +
                              "parameter (with a value of ""$($name)"") to the Add-Index operation for the " +
                              "$($tableDesc) table's ""$($columnDesc)"" column$($pluralSuffix)."
            }
            'AddPrimaryKeyOperation'
            {
                $name = New-ConstraintName -PrimaryKey -SchemaName $schemaName -TableName $tableName
                $warningMsg = "Primary key constraint names will be required in a future version of Rivet. Please " +
                              "add a ""Name"" parameter (with a value of ""$($name)"") to the Add-PrimaryKey " +
                              "operation for the $($tableDesc) table's ""$($columnDesc)"" column."
            }
            'AddUniqueKeyOperation'
            {
                $name = New-ConstraintName -UniqueKey -SchemaName $schemaName -TableName $tableName -ColumnName $columnName
                $warningMsg = "Unique key constraint names will be required in a future version of Rivet. Please add " +
                              "a ""Name"" parameter (with a value of ""$($name)"") to the Add-UniqueKey " +
                              "operation for the $($tableDesc) table's ""$($columnDesc)"" column$($pluralSuffix)."
            }
            'RemoveDefaultConstraint'
            {
                $name = New-ConstraintName -Default -SchemaName $schemaName -TableName $tableName -ColumnName $columnName
                $warningMsg = "Default constraint names will be required in a future version of Rivet. Please add a " +
                              """Name"" parameter (with a value of ""$($name)"") to the Remove-DefaultConstraint " +
                              "operation for the $($tableDesc) table's ""$($columnDesc)"" column."
            }
            'RemoveForeignKeyOperation'
            {
                $name = New-ConstraintName -ForeignKey 
                                           -SchemaName $schemaName `
                                           -TableName $tableName `
                                           -ReferencesSchema $Operation.ReferencesSchema `
                                           -ReferencesTableName $Operation.ReferencesTableName
                $warningMsg = "Foreign key constraint names will be required in a future version of Rivet. Please " +
                              "add a ""Name"" parameter (with a value of ""$($name)"") to the Remove-ForeignKey " +
                              "operation for the $($tableDesc) table that references the " +
                              "[$($Operation.ReferencesSchemaName)].[$($Operation.ReferencesTableName)] table."
            }
            'RemoveIndexOperation'
            {
                $name = New-ConstraintName -Index -SchemaName $schemaName -TableName $tableName -ColumnName $columnName -Unique:$Operation.Unique
                $warningMsg = "Index names will be required in a future version of Rivet. Please add a ""Name"" " +
                              "parameter (with a value of ""$($name)"") to the Remove-Index operation for the " +
                              "$($tableDesc) table's ""$($columnDesc)"" column$($pluralSuffix)."
            }
            'RemovePrimaryKeyOperation'
            {
                $name = New-ConstraintName -PrimaryKey -SchemaName $schemaName -TableName $tableName
                $warningMsg = "Primay key constraint names will be required in a future version of Rivet. Please " +
                              "add a ""Name"" parameter (with a value of ""$($name)"") to the Remove-PrimaryKey " +
                              "operation for the $($tableDesc) table."
            }
            'RemoveUniqueKeyOperation'
            {
                $name = New-ConstraintName -UniqueKey -SchemaName $schemaName -TableName $tableName -ColumnName $columnName
                $warningMsg = "Unique key constraint names will be required in a future version of Rivet. Please " +
                              "remove the ""ColumnName"" parameter and add a ""Name"" parameter (with a value of " +
                              """$($name)"") to the Remove-UniqueKey operation for the " +
                              "$($tableDesc) table's ""$($columnDesc)"" column$($pluralSuffix)."
            }
        }

        $Operation.Name = $name
        if( $warningMsg )
        {
            Write-Warning -Message $warningMsg
        }

        return $Operation
    }

    end
    {
    }
}