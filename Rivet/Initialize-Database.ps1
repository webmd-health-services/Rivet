
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
    
    if( -not (Test-Table -Name $RivetMigrationsTableName -SchemaName $RivetSchemaName) )
    {
        Add-Table -Name $RivetMigrationsTableName -SchemaName $RivetSchemaName -Column {
            New-Column 'ID' -BigInt -NotNull
            New-Column 'Name' -VarChar 50 -Unicode -NotNull
            New-Column 'Who' -VarChar 50 -Unicode -NotNull
            New-Column 'ComputerName' -VarChar 50 -Unicode -NotNull
            New-Column 'AtUtc' -DataType 'datetime' -NotNull
        }

        $query = @'
            alter table {0} add constraint MigrationsPK primary key (ID)
            alter table {0} add constraint AtUtcDefault default (GetUtcDate()) for AtUtc
'@ -f $RivetMigrationsTableFullName
        Invoke-Query -Query $query
    }
}
