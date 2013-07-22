
function Initialize-Database
{
    <#
    .SYNOPSIS
    Intializes the database so that it can be migrated by Rivet.
    #>
    param(
    )

    if( -not (Test-Schema -Name $RivetSchemaName) )
    {
        Add-Schema -Name $RivetSchemaName
    }
    
    $oldRivetSchemaName = 'pstep'
    if( (Test-Table -Name $RivetMigrationsTableName -SchemaName $oldRivetSchemaName) )
    {
        Invoke-Query ('alter schema {0} transfer {1}.Migrations' -f $RivetSchemaName,$oldRivetSchemaName)
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
            New-Column 'ID' -BigInt -NotNull
            New-Column 'Name' -VarChar 50 -Unicode -NotNull
            New-Column 'Who' -VarChar 50 -Unicode -NotNull
            New-Column 'ComputerName' -VarChar 50 -Unicode -NotNull
            New-Column 'AtUtc' -Datetime2 -NotNull
        }

        $query = @'
            alter table {0} add constraint MigrationsPK primary key (ID)
            alter table {0} add constraint AtUtcDefault default (GetUtcDate()) for AtUtc
'@ -f $RivetMigrationsTableFullName
        Invoke-Query -Query $query
    }

}
