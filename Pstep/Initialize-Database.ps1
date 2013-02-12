
function Initialize-Database
{
    <#
    .SYNOPSIS
    Intializes the database so that it can be migrated by Pstep.
    
    .DESCRIPTION
    This is an internal Pstep function that is called whenver you import Pstep.  You should never call it.
    #>
    param(
    )
    
    $dbCountQuery = 'select count(*) from sys.databases where name = @Name'
    $dbCount = Invoke-Query -Query $dbCountQuery -Database 'master' -Parameter @{ Name = $Database } -Scalar
    
    if( $dbCount -eq 0 )
    {
        Write-Host ('Creating database {0}.' -f $Database)
        $query = ('create database [{0}]' -f $Database)
        Invoke-Query -Query $query -NonQuery -Database 'master'
    }
    
    $query = 'select count(*) from sys.schemas where name = ''pstep'''
    $schemaCount = Invoke-Query -Query $query -Scalar
    if( $schemaCount -eq 0 )
    {
        Write-Host ('Creating schema pstep.')
        $query = 'create schema [pstep]'

        Invoke-Query -Query $query -NonQuery
    }
    
    $query = @'
        select count(*) from sys.tables t inner join 
            sys.schemas s on t.schema_id=s.schema_id 
            where s.name = 'pstep' and t.name = 'Migrations'
'@
    $tableCount = Invoke-Query -Query $query -Scalar
    if( $tableCount -eq 0 )
    {
        Write-Host ('Creating table pstep.Migrations')
        $query = @'
    create table pstep.Migrations (
        ID bigint not null,
        Name nvarchar(50) not null,
        Who nvarchar(50) not null,
        ComputerName nvarchar(50) not null,
        AtUtc datetime not null
    )

    alter table pstep.Migrations add constraint MigrationsPK primary key (ID)
    alter table pstep.Migrations add constraint AtUtcDefault default (GetUtcDate()) for AtUtc
'@
        Invoke-Query -Query $query -NonQuery
    }
}