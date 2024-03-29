
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

        function Repair-DefaultConstraintName
        {
            param(
                [Parameter(Mandatory,ValueFromPipeline)]
                [Rivet.Column]$Column
            )

            begin
            {
                Set-StrictMode -Version 'Latest'

                $operationName = 'Add-Table'
                if( $Operation -is [Rivet.Operations.UpdateTableOperation] )
                {
                    $operationName = 'Update-Table'
                }
            }

            process
            {
                if( -not $Column.DefaultExpression -or ($Column.DefaultExpression -and $Column.DefaultConstraintName) )
                {
                    return
                }

                $column.DefaultConstraintName = New-ConstraintName -Default `
                                                                   -SchemaName $schemaName `
                                                                   -TableName $name `
                                                                   -ColumnName $column.Name
                Write-Warning -Message ('Column default constraint names will be required in a future version of ' +
                                        "Rivet. Add a ""DefaultConstraintName"" parameter to the [$($Column.Name)] " +
                                        "column on the $($operationName) operation for the " +
                                        "[$($schemaName)].[$($name)] table.")
            }
        }
    }

    process
    {
        $name = $Operation | Select-Object -ExpandProperty 'Name' -ErrorAction Ignore
        # If a constraint operation already has a name, don't do anything.
        if( $name -and $Operation -isnot [Rivet.Operations.AddTableOperation] -and $Operation -isnot [Rivet.Operations.UpdateTableOperation] )
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
                $Operation.Name = New-ConstraintName -Default -SchemaName $schemaName -TableName $tableName -ColumnName $columnName
                $warningMsg = "Default constraint names will be required in a future version of Rivet. Add a " +
                              """Name"" parameter (with a value of ""$($Operation.Name)"") to the Add-DefaultConstraint " +
                              "operation for the $($tableDesc) table's ""$($columnDesc)"" column."
            }
            'AddForeignKeyOperation'
            {
                $Operation.Name = New-ConstraintName -ForeignKey `
                                                     -SchemaName $schemaName `
                                                     -TableName $tableName `
                                                     -ReferencesSchemaName $Operation.ReferencesSchemaName `
                                                     -ReferencesTableName $Operation.ReferencesTableName
                $warningMsg = "Foreign key constraint names will be required in a future version of Rivet. " +
                              "Add a ""Name"" parameter (with a value of ""$($Operation.Name)"") to the Add-ForeignKey " +
                              "operation for the $($tableDesc) table's $($columnDesc) column$($pluralSuffix)."
            }
            'AddIndexOperation'
            {
                $Operation.Name = New-ConstraintName -Index -SchemaName $schemaName -TableName $tableName -ColumnName $columnName -Unique:$Operation.Unique
                $warningMsg = "Index names will be required in a future version of Rivet. Add a ""Name"" " +
                              "parameter (with a value of ""$($Operation.Name)"") to the Add-Index operation for the " +
                              "$($tableDesc) table's ""$($columnDesc)"" column$($pluralSuffix)."
            }
            'AddPrimaryKeyOperation'
            {
                $Operation.Name = New-ConstraintName -PrimaryKey -SchemaName $schemaName -TableName $tableName
                $warningMsg = "Primary key constraint names will be required in a future version of Rivet. " +
                              "Add a ""Name"" parameter (with a value of ""$($Operation.Name)"") to the Add-PrimaryKey " +
                              "operation for the $($tableDesc) table's $($columnDesc) column."
            }
            'AddTableOperation'
            {
                $Operation.Columns | Repair-DefaultConstraintName
            }
            'AddUniqueKeyOperation'
            {
                $Operation.Name = New-ConstraintName -UniqueKey -SchemaName $schemaName -TableName $tableName -ColumnName $columnName
                $warningMsg = "Unique key constraint names will be required in a future version of Rivet. Add " +
                              "a ""Name"" parameter (with a value of ""$($Operation.Name)"") to the Add-UniqueKey " +
                              "operation on the $($tableDesc) table's $($columnDesc) column$($pluralSuffix)."
            }
            'RemoveDefaultConstraint'
            {
                $Operation.Name = New-ConstraintName -Default -SchemaName $schemaName -TableName $tableName -ColumnName $columnName
                $warningMsg = "Default constraint names will be required in a future version of Rivet. Add a " +
                              """Name"" parameter (with a value of ""$($Operation.Name)"") to the Remove-DefaultConstraint " +
                              "operation for the $($tableDesc) table's ""$($columnDesc)"" column."
            }
            'RemoveForeignKeyOperation'
            {
                $Operation.Name = New-ConstraintName -ForeignKey `
                                                     -SchemaName $schemaName `
                                                     -TableName $tableName `
                                                     -ReferencesSchema $Operation.ReferencesSchema `
                                                     -ReferencesTableName $Operation.ReferencesTableName
                $warningMsg = "Foreign key constraint names will be required in a future version of Rivet. " +
                              "Add a ""Name"" parameter (with a value of ""$($Operation.Name)"") to the Remove-ForeignKey " +
                              "operation for the $($tableDesc) table that references the " +
                              "[$($Operation.ReferencesSchemaName)].[$($Operation.ReferencesTableName)] table."
            }
            'RemoveIndexOperation'
            {
                $Operation.Name = New-ConstraintName -Index -SchemaName $schemaName -TableName $tableName -ColumnName $columnName -Unique:$Operation.Unique
                $warningMsg = "Index names will be required in a future version of Rivet. Add a ""Name"" " +
                              "parameter (with a value of ""$($Operation.Name)"") to the Remove-Index operation for the " +
                              "$($tableDesc) table's ""$($columnDesc)"" column$($pluralSuffix)."
            }
            'RemovePrimaryKeyOperation'
            {
                $Operation.Name = New-ConstraintName -PrimaryKey -SchemaName $schemaName -TableName $tableName
                $warningMsg = "Primay key constraint names will be required in a future version of Rivet. " +
                              "Add a ""Name"" parameter (with a value of ""$($Operation.Name)"") to the Remove-PrimaryKey " +
                              "operation for the $($tableDesc) table."
            }
            'RemoveUniqueKeyOperation'
            {
                $Operation.Name = New-ConstraintName -UniqueKey -SchemaName $schemaName -TableName $tableName -ColumnName $columnName
                $warningMsg = "Unique key constraint names will be required in a future version of Rivet. " +
                              "Remove the ""ColumnName"" parameter and add a ""Name"" parameter (with a value of " +
                              """$($Operation.Name)"") to the Remove-UniqueKey operation for the " +
                              "$($tableDesc) table's ""$($columnDesc)"" column$($pluralSuffix)."
            }
            'UpdateTableOperation'
            {
                $Operation.AddColumns | Repair-DefaultConstraintName
            }
        }

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