
function Initialize-Database
{
    <#
    .SYNOPSIS
    Intializes the database so that it can be migrated by Rivet.
    #>
    param(
    )

    $Connection.Transaction = $Connection.BeginTransaction()

    try
    {
        if( -not (Test-Schema -Name $RivetSchemaName) )
        {
            Add-Schema -Name $RivetSchemaName
        }
    
        $oldRivetSchemaName = 'pstep'
        if( (Test-Table -Name $RivetMigrationsTableName -SchemaName $oldRivetSchemaName) )
        {
            Invoke-Query ('alter schema {0} transfer {1}.Migrations' -f $RivetSchemaName,$oldRivetSchemaName)
        }

        if( (Test-Table -Name $RivetActivityTableName -SchemaName $oldRivetSchemaName) )
        {
            Invoke-Query ('alter schema {0} transfer {1}.Activity' -f $RivetSchemaName,$oldRivetSchemaName)
        }

        if( (Test-Schema -Name $oldRivetSchemaName) )
        {
            Remove-Schema -Name $oldRivetSchemaName
        }
    
        if( (Test-Table -Name $RivetMigrationsTableName -SchemaName $RivetSchemaName) )
        {
            $query = @'
                select 
                    ty.name 
                from 
                    sys.tables t 
                    join sys.schemas s on t.schema_id = s.schema_id
                    join sys.columns c on t.object_id = c.object_id 
                    join sys.types ty on c.system_type_id = ty.system_type_id AND C.user_type_id = ty.user_type_id 
                where 
                    s.name = '{0}' and t.name = '{1}' and c.name = 'AtUtc'
'@ -f $RivetSchemaName,$RivetMigrationsTableName
            $atUtcType = Invoke-Query $query -AsScalar
            if( $atUtcType -eq 'datetime' )
            {
                Write-Host (' {0}.{1}.AtUtc datetime -> datetime2' -f $RivetSchemaName,$RivetMigrationsTableName)
                $query = @'
                alter table {0}.{1} drop constraint AtUtcDefault
                alter table {0}.{1} alter column AtUtc datetime2 not null
                alter table {0}.{1} add constraint AtUtcDefault default (GetUtcDate()) for AtUtc
'@ -f $RivetSchemaName,$RivetMigrationsTableName
                Invoke-Query $query
            }
        }
        else
        {
            Add-Table -Name $RivetMigrationsTableName -SchemaName $RivetSchemaName -Column {
                BigInt ID -NotNull 
                NVarChar 'Name' -Size 50 -NotNull
                NVarChar 'Who' -Size 50  -NotNull
                NVarChar 'ComputerName' -Size 50 -NotNull
                DateTime2 'AtUtc' -NotNull
            }

            
            $query = @'
                alter table {0} add constraint MigrationsPK primary key (ID)
                alter table {0} add constraint AtUtcDefault default (GetUtcDate()) for AtUtc
'@ -f $RivetMigrationsTableFullName
            

            Invoke-Query -Query $query
        }

        if( -not (Test-Table -Name $RivetActivityTableName -SchemaName $RivetSchemaName) )
        {
            Add-Table -SchemaName $RivetSchemaName $RivetActivityTableName {
                int ID -Identity
                nvarchar 'Operation' -Size 4 -NotNull
                bigint 'MigrationID' -NotNull
                nvarchar 'Name' -Size 50 -NotNull
                nvarchar 'Who' -Size 50 -NotNull
                nvarchar 'ComputerName' -Size 50 -NotNull
                datetime2 'AtUtc' -NotNull
            }
            
            Add-PrimaryKey -SchemaName $RivetSchemaName $RivetActivityTableName -ColumnName 'ID'
            Add-DefaultConstraint -SchemaName $RivetSchemaName $RivetActivityTableName -ColumnName 'AtUtc' -Expression 'getutcdate()'
            Add-CheckConstraint -SchemaName $RivetSchemaName -TableName $RivetActivityTableName -Name 'CK_rivet_Activity_Operation' -Expression 'Operation = ''Push'' or Operation = ''Pop'''
        }

        $Connection.Transaction.Commit()
    }
    catch
    {
        $Connection.Transaction.Rollback()
            
         Write-RivetError -Message ('Migration {0} failed' -f $migrationInfo.FullName) -CategoryInfo $_.CategoryInfo.Category -ErrorID $_.FullyQualifiedErrorID -Exception $_.Exception -CallStack ($_.ScriptStackTrace)
    }

}
