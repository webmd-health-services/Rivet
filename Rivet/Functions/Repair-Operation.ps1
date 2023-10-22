
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

        switch( $Operation.GetType().Name )
        {
            'AddDefaultConstraintOperation'
            {
                $Operation.Name = New-ConstraintName -Default -SchemaName $schemaName -TableName $tableName -ColumnName $columnName
            }
            'AddForeignKeyOperation'
            {
                $Operation.Name = New-ConstraintName -ForeignKey `
                                                     -SchemaName $schemaName `
                                                     -TableName $tableName `
                                                     -ReferencesSchemaName $Operation.ReferencesSchemaName `
                                                     -ReferencesTableName $Operation.ReferencesTableName
            }
            'AddIndexOperation'
            {
                $Operation.Name = New-ConstraintName -Index -SchemaName $schemaName -TableName $tableName -ColumnName $columnName -Unique:$Operation.Unique
            }
            'AddPrimaryKeyOperation'
            {
                $Operation.Name = New-ConstraintName -PrimaryKey -SchemaName $schemaName -TableName $tableName
            }
            'AddTableOperation'
            {
                $Operation.Columns | Repair-DefaultConstraintName
            }
            'AddUniqueKeyOperation'
            {
                $Operation.Name = New-ConstraintName -UniqueKey -SchemaName $schemaName -TableName $tableName -ColumnName $columnName
            }
            'RemoveDefaultConstraint'
            {
                $Operation.Name = New-ConstraintName -Default -SchemaName $schemaName -TableName $tableName -ColumnName $columnName
            }
            'RemoveForeignKeyOperation'
            {
                $Operation.Name = New-ConstraintName -ForeignKey `
                                                     -SchemaName $schemaName `
                                                     -TableName $tableName `
                                                     -ReferencesSchema $Operation.ReferencesSchema `
                                                     -ReferencesTableName $Operation.ReferencesTableName
            }
            'RemoveIndexOperation'
            {
                $Operation.Name = New-ConstraintName -Index -SchemaName $schemaName -TableName $tableName -ColumnName $columnName -Unique:$Operation.Unique
            }
            'RemovePrimaryKeyOperation'
            {
                $Operation.Name = New-ConstraintName -PrimaryKey -SchemaName $schemaName -TableName $tableName
            }
            'RemoveUniqueKeyOperation'
            {
                $Operation.Name = New-ConstraintName -UniqueKey -SchemaName $schemaName -TableName $tableName -ColumnName $columnName
            }
            'UpdateTableOperation'
            {
                $Operation.AddColumns | Repair-DefaultConstraintName
            }
        }

        return $Operation
    }
}