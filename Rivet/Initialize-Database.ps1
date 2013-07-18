
function Initialize-Database
{
    <#
    .SYNOPSIS
    Intializes the database so that it can be migrated by Rivet.
    #>
    param(
    )
    
    $query = 'select count(*) from sys.schemas where name = ''{0}''' -f $RivetSchemaName
    $schemaCount = Invoke-Query -Query $query -AsScalar
    if( $schemaCount -eq 0 )
    {
        Write-Host ('Creating schema {0}.' -f $RivetSchemaName)
        $query = 'create schema [{0}]' -f $RivetSchemaName
        Invoke-Query -Query $query
    }
    
    $query = @'
        select count(*) from sys.tables t inner join 
            sys.schemas s on t.schema_id=s.schema_id 
            where s.name = '{0}' and t.name = '{1}'
'@ -f $RivetSchemaName,$RivetMigrationsTableName
    $tableCount = Invoke-Query -Query $query -AsScalar
    if( $tableCount -eq 0 )
    {
        Write-Host ('Creating table {0}' -f $RivetMigrationsTableFullName)
        $query = @'
            create table {0} (
                ID bigint not null,
                Name nvarchar(50) not null,
                Who nvarchar(50) not null,
                ComputerName nvarchar(50) not null,
                AtUtc datetime not null
            )

            alter table {0} add constraint MigrationsPK primary key (ID)
            alter table {0} add constraint AtUtcDefault default (GetUtcDate()) for AtUtc
'@ -f $RivetMigrationsTableFullName
        Invoke-Query -Query $query
    }
}
