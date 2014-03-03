
function Get-ForeignKey
{
    <#
    .SYNOPSIS
    Contains a row per object that is a FOREIGN KEY constraint, with sys.object.type = F.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the table whose foreign key to get.
        $TableName,

        [Parameter()]
        [string]
        # The schema name of the table.  Defaults to `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true)]
        [string]
        # The table that the foreign key references
        $References,

        [Parameter()]
        [string]
        # The schema name of the reference table.  Defaults to `dbo`.
        $ReferencesSchema = 'dbo'        
    )
    
    Set-StrictMode -Version Latest

    $name = New-Object 'Rivet.ForeignKeyConstraintName' ($SchemaName,$TableName,$ReferencesSchema,$References)

    $query = @'
    select 
        SCHEMA_NAME(fk.schema_id) schema_name, t.name table_name, SCHEMA_NAME(reft.schema_id) references_schema_name, reft.name references_table_name, fk.* 
    from 
        sys.foreign_keys fk join
        sys.tables t on fk.parent_object_id=t.object_id join
        sys.tables reft on fk.referenced_object_id=reft.object_id
    where fk.name = '{0}'
'@ -f $name

    $fk = Invoke-RivetTestQuery -Query $query

    if( $fk )
    {
        $query = @'
    select 
        SCHEMA_NAME(t.schema_id) schema_name, t.name table_name, c.name column_name, SCHEMA_NAME(reft.schema_id) referenced_schema_name, reft.name referenced_table_name, refc.name referenced_column_name, fk.* 
    from 
        sys.foreign_key_columns fk 
        join sys.columns c on fk.parent_object_id=c.object_id and fk.parent_column_id=c.column_id
        join sys.tables t on fk.parent_object_id=t.object_id
        join sys.columns refc on fk.referenced_object_id=refc.object_id and fk.referenced_column_id=refc.column_id
        join sys.tables reft on fk.referenced_object_id=reft.object_id
    where 
        constraint_object_id={0}
'@ -f $fk.object_id

        $columns = Invoke-RivetTestQuery -Query $query
        
        Add-Member -InputObject $fk -MemberType NoteProperty -Name 'Columns' -Value $columns -PassThru
    }

}