
function Export-Migration
{
    <#
    .SYNOPSIS
    Exports objects from a database as Rivet migrations.

    .DESCRIPTION
    The `Export-Migration` function exports database objects, schemas, and data types as a Rivet migration. By default, it exports *all* non-system, non-Rivet objects, data types, and schemas. You can filter specific objects by passing their full name to the `Include` parameter. Wildcards are supported. Objects are matched on their schema *and* name.

    Extended properties are *not* exported, except table and column descriptions.

    .EXAMPLE
    Export-Migration -SqlServerName 'some\instance' -Database 'database'

    Demonstrates how to export an entire database.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        # The connection string for the database to connect to.
        $SqlServerName,

        [Parameter(Mandatory)]
        [string]
        # The database to connect to.
        $Database,

        [string[]]
        # The names of the objects to export. Must include the schema if exporting a specific object. Wildcards supported.
        #
        # The default behavior is to export all non-system objects.
        $Include,

        [string[]]
        # The names of any objects *not* to export. Matches the object name *and* its schema name, i.e. `schema.name`. Wildcards supported.
        $Exclude,

        [string[]]
        [ValidateSet('CheckConstraint','DataType','DefaultConstraint','ForeignKey','Function','Index','PrimaryKey','Schema','StoredProcedure','Synonym','Table','Trigger','UniqueKey','View','XmlSchema')]
        # Any object types to exclude.
        $ExcludeType,

        [Switch]
        $NoProgress
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $pops = New-Object 'Collections.Generic.Stack[string]'
    $popsHash = @{}
    $exportedObjects = @{ }
    $exportedSchemas = @{ 
                            'dbo' = $true;
                            'guest' = $true;
                            'sys' = $true;
                            'INFORMATION_SCHEMA' = $true;
                        }
    $exportedTypes = @{ }
    $exportedIndexes = @{ }
    $exportedXmlSchemas = @{ }
    $rivetColumnTypes = Get-Alias | 
                            Where-Object { $_.Source -eq 'Rivet' } | 
                            Where-Object { $_.ReferencedCommand -like 'New-*Column' } | 
                            Select-Object -ExpandProperty 'Name'

    $dependencies = @{ }
    $externalDependencies = @{ }
    $indentLevel = 0

    $timer = New-Object 'Timers.Timer' 100

    $checkConstraints = @()
    $checkConstraintsByID = @{}
    $columns = @()
    $columnsByTable = @{}
    $dataTypes = @()
    $defaultConstraints = @()
    $defaultConstraintsByID = @{}
    $foreignKeys = @()
    $foreignKeysByID = @{}
    $foreignKeyColumns = @()
    $foreignKeyColumnsByObjectID = @{}
    $indexes = @()
    $indexesByObjectID = @{}
    $indexColumns = @()
    $indexColumnsByObjectID = @{}
    $objects = @()
    $objectsByID = @{}
    $objectsByParentID = @{}
    $primaryKeys = @()
    $primaryKeysByID = @{}
    $primaryKeyColumns = @()
    $primaryKeyColumnsByObjectID = @{}
    $schemas = @()
    $schemasByName = @{}
    $modules = @()
    $modulesByID = @{}
    $storedProcedures = @()
    $storedProceduresByID = @{}
    $synonyms = @()
    $synonymsByID = @{}
    $triggers = @()
    $triggersByID = @{}
    $triggersByTable = @{}
    $uniqueKeys = @()
    $uniqueKeysByID = @{}
    $uniqueKeysByTable = @{}
    $uniqueKeyColumnsByObjectID = @()
    $uniqueKeyColumnsByObjectID = @{}
    $functions = @()
    $functionsByID = @{}
    $views = @()
    $viewByID = @{}
    $xmlSchemaDependencies = @{ }
    $xmlSchemasByID = @{ }

    $exclusionTypeMap = @{ 
        'CheckConstraint' = 'CHECK_CONSTRAINT';
        'DefaultConstraint' = 'DEFAULT_CONSTRAINT';
        'ForeignKey' = 'FOREIGN_KEY_CONSTRAINT';
        'Function' = @('SQL_INLINE_TABLE_VALUED_FUNCTION','SQL_SCALAR_FUNCTION','SQL_TABLE_VALUED_FUNCTION');
        'PrimaryKey' = 'PRIMARY_KEY_CONSTRAINT';
        'StoredProcedure' = 'SQL_STORED_PROCEDURE';
        'Synonym' = 'SYNONYM';
        'Table' = 'USER_TABLE';
        'Trigger' = 'SQL_TRIGGER';
        'UniqueKey' = 'UNIQUE_CONSTRAINT';
        'View' = 'VIEW';
    }


    function ConvertTo-SchemaParameter
    {
        param(
            [Parameter(Mandatory)]
            [AllowNull()]
            [AllowEmptyString()]
            [string]
            $SchemaName,

            [string]
            $ParameterName = 'SchemaName'
        )

        $parameter = ''
        if( $SchemaName -and $SchemaName -ne 'dbo' )
        {
            $parameter = ' -{0} ''{1}''' -f $ParameterName,$SchemaName
        }
        return $parameter
    }

    function Get-ChildObject
    {
        param(
            [Parameter(Mandatory)]
            [int]
            $TableID,

            [Parameter(Mandatory)]
            [string]
            $Type
        )

        if( $objectsByParentID.ContainsKey($TableID) )
        {
            $objectsByParentID[$TableID] | Where-Object { $_.type -eq $Type }
        }
    }

    $checkConstraintsQuery = '
-- CHECK CONSTRAINTS
select 
    sys.check_constraints.object_id,
    schema_name(sys.tables.schema_id) as schema_name, 
    sys.tables.name as table_name, 
    sys.check_constraints.name as name, 
    sys.check_constraints.is_not_trusted,
	sys.check_constraints.is_not_for_replication,
	sys.check_constraints.is_disabled,
    sys.check_constraints.definition
from 
    sys.check_constraints 
        join 
    sys.tables 
            on sys.check_constraints.parent_object_id = sys.tables.object_id
--where
--    sys.check_constraints.object_id = @object_id'
    function Export-CheckConstraint
    {
        param(
            [Parameter(Mandatory,ParameterSetName='ByObject')]
            [object]
            $Object,

            [Parameter(Mandatory,ParameterSetName='ByTableID')]
            [int]
            $TableID,

            [Switch]
            $ForTable
        )

        if( $TableID )
        {
            $objects = Get-ChildObject -TableID $TableID -Type 'C'
            foreach( $object in $objects )
            {
                Export-CheckConstraint -Object $object -ForTable:$ForTable
            }
            return
        }

        $constraint = $checkConstraintsByID[$Object.object_id]
        if( -not $ForTable )
        {
            Export-Object -ObjectID $Object.parent_object_id
        }

        if( $exportedObjects.ContainsKey($Object.object_id) )
        {
            continue
        }
            
        Export-DependentObject -ObjectID $constraint.object_id

        Write-ExportingMessage -Schema $constraint.schema_name -Name $constraint.name -Type CheckConstraint

        $notChecked = ''
        if( $constraint.is_not_trusted )
        {
            $notChecked = ' -NoCheck'
        }

        $notForReplication = ''
        if( $constraint.is_not_for_replication )
        {
            $notForReplication = ' -NotForReplication'
        }

        $schema = ConvertTo-SchemaParameter -SchemaName $constraint.schema_name
        '    Add-CheckConstraint{0} -TableName ''{1}'' -Name ''{2}'' -Expression ''{3}''{4}{5}' -f $schema,$constraint.table_name,$constraint.name,($constraint.definition -replace '''',''''''),$notForReplication,$notChecked
        if( $constraint.is_disabled )
        {
            '    Disable-Constraint{0} -TableName ''{1}'' -Name ''{2}''' -f $schema,$constraint.table_name,$constraint.name
        }
        if( -not $ForTable )
        {
            Push-PopOperation ('Remove-CheckConstraint{0} -TableName ''{1}'' -Name ''{2}''' -f $schema,$constraint.table_name,$constraint.name)
        }
        $exportedObjects[$constraint.object_id] = $true
    }

    $columnsQuery = '
-- COLUMNS
select 
    sys.columns.object_id,
    sys.columns.is_nullable,
	sys.types.name as type_name, 
	sys.columns.name as column_name, 
	sys.types.collation_name as type_collation_name, 
	sys.columns.max_length as max_length, 
	sys.extended_properties.value as description,
    sys.columns.is_identity,
    sys.identity_columns.increment_value,
    sys.identity_columns.seed_value,
    sys.columns.precision,
    sys.columns.scale,
    sys.types.precision as default_precision,
    sys.types.scale as default_scale,
    sys.columns.is_sparse,
    sys.columns.collation_name,
    serverproperty(''collation'') as default_collation_name,
    sys.columns.is_rowguidcol,
	sys.types.system_type_id,
	sys.types.user_type_id,
    isnull(sys.identity_columns.is_not_for_replication, 0) as is_not_for_replication,
    sys.columns.column_id,
    sys.columns.is_xml_document,
    sys.columns.xml_collection_id,
	sys.xml_schema_collections.name as xml_schema_name,
    sys.types.max_length as default_max_length
from 
	sys.columns 
		inner join 
	sys.types 
			on columns.user_type_id = sys.types.user_type_id  
        left join
	sys.extended_properties
			on sys.columns.object_id = sys.extended_properties.major_id
			and sys.columns.column_id = sys.extended_properties.minor_id
			and sys.extended_properties.name = ''MS_Description''
        left join
    sys.identity_columns
            on sys.columns.object_id = sys.identity_columns.object_id
            and sys.columns.column_id = sys.identity_columns.column_id
		left join
	sys.xml_schema_collections
			on sys.columns.xml_collection_id=sys.xml_schema_collections.xml_collection_id
'
    function Export-Column
    {
        param(
            [Parameter(Mandatory,ParameterSetName='ForTable')]
            [int]
            $TableID
        )

        foreach( $column in ($columnsByTable[$TableID] | Sort-Object -Property 'column_id') )
        {
            $notNull = ''
            $parameters = & {
                $isBinaryVarColumn = $column.type_name -in @( 'varbinary', 'binary' )
                if( $column.type_collation_name -or $isBinaryVarColumn )
                {
                    $isSizable = $column.type_name -in @( 'binary', 'char', 'nchar', 'nvarchar', 'varbinary', 'varchar' )
                    if( $isSizable )
                    {
                        $maxLength = $column.max_length
                        if( $maxLength -eq -1 )
                        {
                            '-Max'
                        }
                        else
                        {
                            if( $column.type_name -like 'n*' )
                            {
                                $maxLength = $maxLength / 2
                            }
                            '-Size {0}' -f $maxLength
                        }
                    }

                    if( $column.collation_name -ne $column.default_collation_name -and -not $isBinaryVarColumn )
                    {
                        '-Collation'
                        '''{0}''' -f $column.collation_name
                    }
                }

                if( $column.type_name -eq 'xml' )
                {
                    if( $column.xml_schema_name )
                    {
                        if( $column.is_xml_document )
                        {
                            '-Document'
                        }
                        '-XmlSchemaCollection'
                        '''{0}''' -f $column.xml_schema_name
                    }
                }

                if( $column.is_rowguidcol )
                {
                    '-RowGuidCol'
                }

                $scaleOnlyTypes = @( 'time','datetime2', 'datetimeoffset' )
                if( $column.precision -ne $column.default_precision -and $column.type_name -notin $scaleOnlyTypes )
                {
                    '-Precision'
                    $column.precision
                }
                if( $column.scale -ne $column.default_scale )
                {
                    '-Scale'
                    $column.scale
                }

                if( $column.is_identity )
                {
                    '-Identity'
                    if( $column.seed_value -ne 1 -or $column.increment_value -ne 1 )
                    {
                        '-Seed'
                        $column.seed_value
                        '-Increment'
                        $column.increment_value
                    }
                }
                if( $column.is_not_for_replication )
                {
                    '-NotForReplication'
                }
                if( -not $column.is_nullable )
                {
                    if( -not $column.is_identity )
                    {
                        '-NotNull'
                    }
                }
                if( $column.is_sparse )
                {
                    '-Sparse'
                }
                if( $column.description )
                {
                    '-Description ''{0}''' -f ($column.description -replace '''','''''')
                }
            }

            if( $parameters )
            {
                $parameters = $parameters -join ' '
                $parameters = ' {0}' -f $parameters
            }

            if( $rivetColumnTypes -contains $column.type_name )
            {
                '        {0} ''{1}''{2}' -f $column.type_name,$column.column_name,$parameters
            }
            else
            {
                '        New-Column -DataType ''{0}'' -Name ''{1}''{2}' -f $column.type_name,$column.column_name,$parameters
            }
        }
    }

    $dataTypesQuery = '
-- DATA TYPES
select 
    schema_name(sys.types.schema_id) as schema_name, 
    sys.types.name, 
    sys.types.max_length,
    sys.types.precision,
    sys.types.scale,
    sys.types.collation_name,
    sys.types.is_nullable,
    systype.name as from_name, 
    systype.max_length as from_max_length,
    systype.precision as from_precision,
    systype.scale as from_scale,
    systype.collation_name as from_collation_name,
    sys.types.is_table_type,
    sys.table_types.type_table_object_id
from 
    sys.types 
        left join 
    sys.types systype 
            on sys.types.system_type_id = systype.system_type_id 
            and sys.types.system_type_id = systype.user_type_id 
        left join
    sys.table_types
            on sys.types.user_type_id = sys.table_types.user_type_id
where 
    sys.types.is_user_defined = 1'
    function Export-DataType
    {
        [CmdletBinding(DefaultParameterSetName='All')]
        param(
            [Parameter(Mandatory,ParameterSetName='ByDataType')]
            [object]
            $Object
        )

        if( $ExcludeType -contains 'DataType' )
        {
            return
        }

        if( $PSCmdlet.ParameterSetName -eq 'All' )
        {
            foreach( $object in $dataTypes )
            {
                if( (Test-SkipObject -SchemaName $object.schema_name -Name $object.name) )
                {
                    continue
                }
                Export-DataType -Object $object
            }
            return
        }

        if( $exportedTypes.ContainsKey($Object.name) )
        {
            Write-Debug ('Skipping   ALREADY EXPORTED  {0}' -f $Object.name)
            continue
        }
        
        Export-Schema -Name $Object.schema_name

        Write-ExportingMessage -SchemaName $Object.schema_name -Name $Object.name -Type DataType

        $schema = ConvertTo-SchemaParameter -SchemaName $Object.schema_name
        if( $Object.is_table_type )
        {
            '    Add-DataType{0} -Name ''{1}'' -AsTable {{' -f $schema,$Object.name
            Export-Column -TableID $Object.type_table_object_id
            '    }'
        }
        else
        {
            $typeDef = $object.from_name
            if( $object.from_collation_name )
            {
                if( $object.max_length -ne $object.from_max_length )
                {
                    $maxLength = $object.max_length
                    if( $maxLength -eq -1 )
                    {
                        $maxLength = 'max'
                    }
                    $typeDef = '{0}({1})' -f $typeDef,$maxLength
                }
            }
            else
            {
                if( ($object.precision -ne $object.from_precision) -or ($object.scale -ne $object.from_scale) )
                {
                    $typeDef = '{0}({1},{2})' -f $typeDef,$object.precision,$object.scale
                }
            }

            if( -not $object.is_nullable )
            {
                $typeDef = '{0} not null' -f $typeDef
            }

            '    Add-DataType{0} -Name ''{1}'' -From ''{2}''' -F $schema,$Object.name,$typeDef
        }
        Push-PopOperation ('Remove-DataType{0} -Name ''{1}''' -f $schema,$Object.name)
        $exportedtypes[$object.name] = $true
    }

    $defaultConstraintsQuery = '
-- DEFAULT CONSTRAINTS
select 
    schema_name(sys.tables.schema_id) as schema_name, 
    sys.tables.name as table_name, 
    sys.default_constraints.name as name, 
    sys.columns.name as column_name, 
    definition,
    sys.default_constraints.object_id,
	sys.default_constraints.parent_object_id
from 
    sys.objects 
        join 
    sys.default_constraints
            on sys.default_constraints.object_id = sys.objects.object_id
	    join 
    sys.columns 
	    	on sys.columns.object_id = sys.default_constraints.parent_object_id
		    and sys.columns.column_id = sys.default_constraints.parent_column_id
        left join 
    sys.tables 
            on sys.objects.parent_object_id = sys.tables.object_id
        left join 
    sys.schemas
            on sys.schemas.schema_id = sys.tables.schema_id
-- where
--    sys.default_constraints.object_id = @object_id'
    function Export-DefaultConstraint
    {
        param(
            [Parameter(Mandatory,ParameterSetName='ByObject')]
            [object]
            $Object,

            [Parameter(Mandatory,ParameterSetName='ByTableID')]
            [int]
            $TableID,

            [Switch]
            $ForTable
        )

        if( $TableID )
        {
            $objects = Get-ChildObject -TableID $TableID -Type 'D'
            foreach( $item in $objects )
            {
                Export-DefaultConstraint -Object $item -ForTable:$ForTable
            }
            return
        }

        $constraint = $defaultConstraintsByID[$Object.object_id]
        if( -not $constraint )
        {
            Write-Warning -Message ('Unable to export default constraint [{0}].[{1}] ({2}): its metadata is missing from the databse.' -f $Object.schema_name,$Object.name,$Object.object_id)
            $exportedObjects[$Object.object_id] = $true
            return
        }

        # Default constraint isn't on a table
        if( $constraint.table_name -eq $null )
        {
            $exportedObjects[$Object.object_id] = $true
            return
        }

        if( -not $ForTable )
        {
            Export-Object -ObjectID $constraint.parent_object_id
        }

        if( $exportedObjects.ContainsKey($constraint.object_id) )
        {
            continue
        }

        Export-DependentObject -ObjectID $constraint.object_id

        Write-ExportingMessage -Schema $Object.schema_name -Name $constraint.name -Type DefaultConstraint
        $schema = ConvertTo-SchemaParameter -SchemaName $constraint.schema_name
        '    Add-DefaultConstraint{0} -TableName ''{1}'' -ColumnName ''{2}'' -Name ''{3}'' -Expression ''{4}''' -f $schema,$Object.parent_object_name,$constraint.column_name,$constraint.name,($constraint.definition -replace '''','''''')
        if( -not $ForTable )
        {
            Push-PopOperation ('Remove-DefaultConstraint{0} -TableName ''{1}'' -Name ''{2}''' -f $schema,$Object.parent_object_name,$constraint.name)
        }
        $exportedObjects[$constraint.object_id] = $true
    }

    function Export-DependentObject
    {
        param(
            [Parameter(Mandatory)]
            [int]
            $ObjectID
        )

        $indentLevel += 1
        try
        {
            if( $dependencies.ContainsKey($ObjectID) )
            {
                foreach( $dependencyID in $dependencies[$ObjectID].Keys )
                {
                    Export-Object -ObjectID $dependencyID
                }
            }

            if( $xmlSchemaDependencies.ContainsKey($ObjectID) )
            {
                foreach( $xmlSchemaID in $xmlSchemaDependencies[$ObjectID] )
                {
                    Export-XmlSchema -ID $xmlSchemaID
                }
            }
        }
        finally
        {
            $indentLevel -= 1
        }
    }

    $foreignKeysQuery = '
-- FOREIGN KEYS
select
    sys.foreign_keys.object_id,
    is_not_trusted,
    is_not_for_replication,
    delete_referential_action_desc,
    update_referential_action_desc,
    schema_name(sys.objects.schema_id) as references_schema_name,
    sys.objects.name as references_table_name,
    sys.foreign_keys.referenced_object_id,
    is_disabled
from
    sys.foreign_keys
        join
    sys.objects
        on sys.foreign_keys.referenced_object_id = sys.objects.object_id
'
    $foreignKeyColumnsQuery = '
-- FOREIGN KEY COLUMNS
select 
    sys.foreign_key_columns.constraint_object_id,
	sys.columns.name as name,
	referenced_columns.name as referenced_name,
    sys.foreign_key_columns.constraint_column_id
from 
	sys.foreign_key_columns
		join
	sys.columns
			on sys.foreign_key_columns.parent_object_id = sys.columns.object_id
			and sys.foreign_key_columns.parent_column_id = sys.columns.column_id
		join
	sys.columns as referenced_columns		
			on sys.foreign_key_columns.referenced_object_id = referenced_columns.object_id
			and sys.foreign_key_columns.referenced_column_id = referenced_columns.column_id
'
    function Export-ForeignKey
    {
        param(
            [Parameter(Mandatory)]
            [object]
            $Object
        )

        # Make sure the key's table is exported.
        Export-Object -ObjectID $Object.parent_object_id

        $schema = ConvertTo-SchemaParameter -SchemaName $Object.schema_name
        $foreignKey = $foreignKeysByID[$Object.object_id]

        # Make sure the key's referenced table is exported.
        Export-Object -ObjectID $foreignKey.referenced_object_id

        $referencesSchema = ConvertTo-SchemaParameter -SchemaName $foreignKey.references_schema_name -ParameterName 'ReferencesSchema'
        $referencesTableName = $foreignKey.references_table_name

        $columns = $foreignKeyColumnsByObjectID[$Object.object_id] | Sort-Object -Property 'constraint_column_id'

        $columnNames = $columns | Select-Object -ExpandProperty 'name'
        $referencesColumnNames = $columns | Select-Object -ExpandProperty 'referenced_name'

        $onDelete = ''
        if( $foreignKey.delete_referential_action_desc -ne 'NO_ACTION' )
        {
            $onDelete = ' -OnDelete ''{0}''' -f $foreignKey.delete_referential_action_desc
        }

        $onUpdate = ''
        if( $foreignKey.update_referential_action_desc -ne 'NO_ACTION' )
        {
            $onUpdate = ' -OnUpdate ''{0}''' -f $foreignKey.update_referential_action_desc
        }

        $notForReplication = ''
        if( $foreignKey.is_not_for_replication )
        {
            $notForReplication = ' -NotForReplication'
        }

        $noCheck = ''
        if( $foreignKey.is_not_trusted )
        {
            $noCheck = ' -NoCheck'
        }

        Write-ExportingMessage -Schema $Object.schema_name -Name $Object.name -Type ForeignKey

        '    Add-ForeignKey{0} -TableName ''{1}'' -ColumnName ''{2}''{3} -References ''{4}'' -ReferencedColumn ''{5}'' -Name ''{6}''{7}{8}{9}{10}' -f $schema,$Object.parent_object_name,($columnNames -join ''','''),$referencesSchema,$referencesTableName,($referencesColumnNames -join ''','''),$Object.name,$onDelete,$onUpdate,$notForReplication,$noCheck
        if( $foreignKey.is_disabled )
        {
            '    Disable-Constraint{0} -TableName ''{1}'' -Name ''{2}''' -f $schema,$Object.parent_object_name,$Object.name
        }
        Push-PopOperation ('Remove-ForeignKey{0} -TableName ''{1}'' -Name ''{2}''' -f $schema,$Object.parent_object_name,$Object.name)
        $exportedObjects[$Object.object_id] = $true
    }

    $indexesQuery = '
-- INDEXES
select 
    sys.indexes.object_id,
    schema_name(sys.tables.schema_id) as schema_name,
    sys.indexes.name,
    sys.tables.name as table_name, 
    sys.indexes.is_unique,
    sys.indexes.type_desc,
    sys.indexes.has_filter,
    sys.indexes.filter_definition,
    sys.indexes.index_id
from 
    sys.indexes 
        join 
    sys.tables 
            on sys.indexes.object_id = sys.tables.object_id 
where 
    is_primary_key = 0 and 
    sys.indexes.type != 0 and
    sys.indexes.is_unique_constraint != 1 and
    sys.tables.is_ms_shipped = 0'

    $indexesColumnsQuery = '
-- INDEX COLUMNS
select
    sys.indexes.object_id,
    sys.indexes.index_id,
    sys.columns.name,
    sys.index_columns.key_ordinal,
    sys.index_columns.is_included_column,
    sys.index_columns.is_descending_key
from
	sys.indexes 
		join 
	sys.index_columns 
			on sys.indexes.object_id = sys.index_columns.object_id 
			and sys.indexes.index_id = sys.index_columns.index_id 
		join
	sys.columns
			on sys.indexes.object_id = sys.columns.object_id
			and sys.index_columns.column_id = sys.columns.column_id
-- where 
--    sys.indexes.object_id = @object_id and
--    sys.indexes.index_id = @index_id
'
    function Export-Index
    {
        [CmdletBinding(DefaultParameterSetName='All')]
        param(
            [Parameter(Mandatory,ParameterSetName='ByIndex')]
            [object]
            $Object,

            [Parameter(Mandatory,ParameterSetName='ByTable')]
            [int]
            $TableID,

            [Switch]
            $ForTable
        )

        if( $PSCmdlet.ParameterSetName -eq 'All' )
        {
            foreach( $object in $indexes )
            {
                if( (Test-SkipObject -SchemaName $Object.schema_name -Name $Object.name) -or $ExcludeType -contains 'Index' )
                {
                    continue
                }

                Export-Index -Object $object -ForTable:$ForTable
            }
            return
        }
        elseif( $PSCmdlet.ParameterSetName -eq 'ByTable' )
        {
            foreach( $object in $indexesByObjectID[$TableID] )
            {
                Export-Index -Object $object -ForTable:$ForTable
            }
            return
        }

        if( -not $ForTable )
        {
            Export-Object -ObjectID $Object.object_id
        }

        $indexKey = '{0}_{1}' -f $Object.object_id,$Object.index_id
        if( $exportedIndexes.ContainsKey($indexKey) )
        {
            return
        }

        Export-DependentObject -ObjectID $Object.object_id

        $unique = ''
        if( $Object.is_unique )
        {
            $unique = ' -Unique'
        }
        $clustered = ''
        if( $Object.type_desc -eq 'CLUSTERED' )
        {
            $clustered = ' -Clustered'
        }
        $where = ''
        if( $Object.has_filter )
        {
            $where = ' -Where ''{0}''' -f $Object.filter_definition
        }

        $allColumns = $indexColumnsByObjectID[$Object.object_id] | Where-Object { $_.index_id -eq $Object.index_id }

        $includedColumns = $allColumns | Where-Object { $_.is_included_column } | Sort-Object -Property 'name' # I don't think order matters so order them discretely.
        $include = ''
        if( $includedColumns )
        {
            $include = ' -Include ''{0}''' -f (($includedColumns | Select-Object -ExpandProperty 'name') -join ''',''')
        }

        $columns = $allColumns | Where-Object { -not $_.is_included_column } | Sort-Object -Property 'key_ordinal'

        $descending = ''
        if( $columns | Where-Object { $_.is_descending_key } )
        {
            $descending = $columns | Select-Object -ExpandProperty 'is_descending_key' | ForEach-Object { if( $_ ) { '$true' } else { '$false' } }
            $descending = ' -Descending {0}' -f ($descending -join ',')
        }

        $columnNames = $columns | Select-Object -ExpandProperty 'name'
        Write-ExportingMessage -Schema $Object.schema_name -Name $Object.name -Type Index
        $schema = ConvertTo-SchemaParameter -SchemaName $Object.schema_name
        '    Add-Index{0} -TableName ''{1}'' -ColumnName ''{2}'' -Name ''{3}''{4}{5}{6}{7}{8}' -f $schema,$Object.table_name,($columnNames -join ''','''),$Object.name,$clustered,$unique,$include,$descending,$where
        if( -not $ForTable )
        {
            Push-PopOperation ('Remove-Index{0} -TableName ''{1}'' -Name ''{2}''' -f $schema,$Object.table_name,$Object.name)
        }
        $exportedIndexes[$indexKey] = $true
    }

    function Get-ModuleDefinition
    {
        param(
            [Parameter(Mandatory)]
            [int]
            $ObjectID
        )

        $modulesByID[$ObjectID].definition
    }

    $objectsQuery = '
-- OBJECTS
select 
    sys.schemas.name as schema_name, 
    sys.objects.name as object_name, 
    sys.objects.name as name,
    sys.schemas.name + ''.'' + sys.objects.name as full_name, 
    sys.extended_properties.value as description,
    parent_objects.name as parent_object_name,
    sys.objects.object_id as object_id,
    RTRIM(sys.objects.type) as type,
    sys.objects.type_desc,
    sys.objects.parent_object_id
from 
    sys.objects 
        join 
    sys.schemas 
            on sys.objects.schema_id = sys.schemas.schema_id 
        left join
    sys.extended_properties
            on sys.objects.object_id = sys.extended_properties.major_id 
            and sys.extended_properties.minor_id = 0
            and sys.extended_properties.name = ''MS_Description''
        left join
    sys.objects parent_objects
        on sys.objects.parent_object_id = parent_objects.object_id
where 
    sys.objects.is_ms_shipped = 0 and
    (parent_objects.is_ms_shipped is null or parent_objects.is_ms_shipped = 0) and
    sys.schemas.name != ''rivet'''
    function Export-Object
    {
        [CmdletBinding(DefaultParameterSetName='All')]
        param(
            [Parameter(Mandatory,ParameterSetName='ByObjectID')]
            [int[]]
            $ObjectID = @()
        )

        $filteredObjects = $objects
        if( $PSCmdlet.ParameterSetName -eq 'ByObjectID' )
        {
            $filteredObjects = $ObjectID | ForEach-Object { $objectsByID[$_] }
        }

        foreach( $object in $filteredObjects )
        {
            if( $exportedObjects.ContainsKey($object.object_id) )
            {
                Write-Debug ('Skipping   ALREADY EXPORTED  {0}' -f $object.full_name)
                continue
            }

            if( (Test-SkipObject -SchemaName $object.schema_name -Name $object.object_name -Type $object.type_desc) )
            {
                continue
            }

            if( $object.schema_name -eq 'rivet' )
            {
                continue
            }

            Export-Schema -Name $object.schema_name

            Export-DependentObject -ObjectID $object.object_id

            if( $exportedObjects.ContainsKey($object.object_id) )
            {
                continue
            }

            if( $externalDependencies.ContainsKey($object.object_id) )
            {
                Write-Warning -Message ('Unable to export {0} {1}: it depends on external object {2}.' -f $object.type_desc,$object.full_name,$externalDependencies[$object.object_id])
                $exportedObjects[$object.object_id] = $true
                continue
            }

            switch ($object.type_desc)
            {
                'CHECK_CONSTRAINT'
                {
                    Export-CheckConstraint -Object $object
                    break
                }
                'DEFAULT_CONSTRAINT'
                {
                    Export-DefaultConstraint -Object $object
                    break
                }
                'FOREIGN_KEY_CONSTRAINT'
                {
                    Export-ForeignKey -Object $object
                    break
                }
                'PRIMARY_KEY_CONSTRAINT'
                {
                    Export-PrimaryKey -Object $object
                    break
                }
                'SQL_INLINE_TABLE_VALUED_FUNCTION'
                {
                    Export-UserDefinedFunction -Object $object
                    break
                }
                'SQL_SCALAR_FUNCTION'
                {
                    Export-UserDefinedFunction -Object $object
                    break
                }
                'SQL_STORED_PROCEDURE'
                {
                    Export-StoredProcedure -Object $object
                    break
                }
                'SQL_TABLE_VALUED_FUNCTION'
                {
                    Export-UserDefinedFunction -Object $object
                    break
                }
                'SQL_TRIGGER'
                {
                    Export-Trigger -Object $object
                    break
                }
                'SYNONYM'
                {
                    Export-Synonym -Object $object
                    break
                }
                'UNIQUE_CONSTRAINT'
                {
                    Export-UniqueKey -Object $object
                    break
                }
                'USER_TABLE'
                {
                    Export-Table -Object $object
                    break
                }
                'VIEW'
                {
                    Export-View -Object $object
                    break
                }

                default
                {
                    Write-Error -Message ('Unable to export object "{0}": unsupported object type "{1}".' -f $object.full_name,$object.type_desc)
                }
            }
            $exportedObjects[$object.object_id] = $true
        }
    }

    # PRIMARY KEYS
    $primaryKeysQuery = '
-- PRIMARY KEYS
select 
	sys.key_constraints.object_id,
    sys.indexes.type_desc
from 
	sys.key_constraints 
		join 
	sys.indexes 
			on sys.key_constraints.parent_object_id = sys.indexes.object_id 
			and sys.key_constraints.unique_index_id = sys.indexes.index_id 
where 
	sys.key_constraints.type = ''PK'' 
	and sys.key_constraints.is_ms_shipped = 0'

    # PRIMARY KEY COLUMNS
    $primaryKeyColumnsQuery = '
-- PRIMARY KEY COLUMNS
select 
    sys.objects.object_id,
	sys.schemas.name as schema_name, 
	sys.tables.name as table_name, 
	sys.columns.name as column_name, 
	sys.indexes.type_desc,
    sys.index_columns.key_ordinal
from 
    sys.objects 
    join sys.tables 
        on sys.objects.parent_object_id = sys.tables.object_id
    join sys.schemas
        on sys.schemas.schema_id = sys.tables.schema_id
    join sys.indexes
        on sys.indexes.object_id = sys.tables.object_id
	join sys.index_columns 
		on sys.indexes.object_id = sys.index_columns.object_id 
        and sys.indexes.index_id = sys.index_columns.index_id
	join sys.columns 
		on sys.indexes.object_id = sys.columns.object_id 
		and sys.columns.column_id = sys.index_columns.column_id
where
--    sys.objects.object_id = @object_id and
	sys.objects.type = ''PK'' and
	sys.indexes.is_primary_key = 1'

    function Export-PrimaryKey
    {
        param(
            [Parameter(Mandatory,ParameterSetName='ByObject')]
            [object]
            $Object,

            [Parameter(Mandatory,ParameterSetName='ByTableID')]
            [int]
            $TableID,

            [Switch]
            $ForTable
        )

        if( $TableID )
        {
            $Object = Get-ChildObject -TableID $TableID -Type 'PK'
            if( -not $Object )
            {
                return
            }
        }

        if( -not $ForTable )
        {
            Export-Object -ObjectID $Object.parent_object_id
        }

        if( $exportedObjects.ContainsKey($Object.object_id) )
        {
            return
        }

        Export-DependentObject -ObjectID $Object.object_id

        $primaryKey = $primaryKeysByID[$Object.object_id]
        $columns = $primaryKeyColumnsByObjectID[$Object.object_id]
        if( -not $columns )
        {
            # PK on a table-valued function.
            $exportedObjects[$Object.object_id] = $true
            return        
        }

        $schema = ConvertTo-SchemaParameter -SchemaName $Object.schema_name
        $columnNames = $columns | Sort-Object -Property 'key_ordinal' | Select-Object -ExpandProperty 'column_name'
        $nonClustered = ''
        if( $primaryKey.type_desc -eq 'NONCLUSTERED' )
        {
            $nonClustered = ' -NonClustered'
        }
        Write-ExportingMessage -Schema $Object.schema_name -Name $Object.name -Type PrimaryKey
        '    Add-PrimaryKey{0} -TableName ''{1}'' -ColumnName ''{2}'' -Name ''{3}''{4}' -f $schema,$Object.parent_object_name,($columnNames -join ''','''),$object.object_name,$nonClustered
        if( -not $ForTable )
        {
            Push-PopOperation ('Remove-PrimaryKey{0} -TableName ''{1}'' -Name ''{2}''' -f $schema,$Object.parent_object_name,$object.object_name)
        }
        $exportedObjects[$Object.object_id] = $true
    }

    $schemasQuery = '
-- SCHEMAS
select 
    sys.schemas.name, 
    sys.sysusers.name as owner,
    sys.extended_properties.value as description
from 
    sys.schemas 
        join 
    sys.sysusers 
            on sys.schemas.principal_id = sys.sysusers.uid
        left join
    sys.extended_properties
            on sys.extended_properties.class = 3
            and sys.extended_properties.major_id = sys.schemas.schema_id
            and sys.extended_properties.name = ''MS_Description'''
    function Export-Schema
    {
        param(
            [Parameter(Mandatory)]
            [string]
            $Name
        )

        if( $exportedSchemas.ContainsKey($Name) )
        {
            return
        }

        $schema = $schemasByName[$Name]
        if( -not $schema )
        {
            return
        }
        $description = $schema.description
        if( $description )
        {
            $description = ' -Description ''{0}''' -f ($description -replace '''','''''')
        }

        Write-ExportingMessage -Schema $Object.schema_name -Type Schema
        '    Add-Schema -Name ''{0}'' -Owner ''{1}''{2}' -f $schema.name,$schema.owner, $description
        $exportedSchemas[$schema.name] = $true
        Push-PopOperation ('Remove-Schema -Name ''{0}''' -f $schema.name)
    }

    function Export-StoredProcedure
    {
        param(
            [Parameter(Mandatory)]
            [object]
            $Object
        )

        Export-DependentObject -ObjectID $Object.object_id

        $query = 'select definition from sys.sql_modules where object_id = @object_id'
        $definition = Get-ModuleDefinition -ObjectID $Object.object_id

        try
        {
            if( -not $definition )
            {
                Write-Warning -Message ('Unable to export stored procedure [{0}].[{1}]: definition not readable.' -f $Object.schema_name,$Object.name)
                return
            }

            $schema = ConvertTo-SchemaParameter -SchemaName $Object.schema_name
            $createPreambleRegex = '^CREATE\s+procedure\s+\[{0}\]\.\[{1}\]\s+' -f [regex]::Escape($Object.schema_name),[regex]::Escape($Object.object_name)
            Write-ExportingMessage -Schema $Object.schema_name -Name $Object.name -Type StoredProcedure
            if( $definition -match $createPreambleRegex )
            {
                $definition = $definition -replace $createPreambleRegex,''
                '    Add-StoredProcedure{0} -Name ''{1}'' -Definition @''{2}{3}{2}''@' -f $schema,$Object.object_name,[Environment]::NewLine,$definition
            }
            else
            {
                '    Invoke-Ddl -Query @''{0}{1}{0}''@' -f [Environment]::NewLine,$definition
            }
            Push-PopOperation ('Remove-StoredProcedure{0} -Name ''{1}''' -f $schema,$Object.object_name)
        }
        finally
        {
            $exportedObjects[$Object.object_id] = $true
        }
    }

    $synonymsQuery = '
-- SYNONYMS
select 
    sys.synonyms.object_id,
    parsename(base_object_name,3) as database_name,
    parsename(base_object_name,2) as schema_name,
    parsename(base_object_name,1) as object_name,
	sys.objects.object_id as target_object_id
from
    sys.synonyms
		left join
	sys.objects
			on parsename(sys.synonyms.base_object_name,2) = schema_name(sys.objects.schema_id) 
			and parsename(sys.synonyms.base_object_name,1) = sys.objects.name
'
    function Export-Synonym
    {
        param(
            [Parameter(Mandatory)]
            [object]
            $Object
        )
        
        $schema = ConvertTo-SchemaParameter -SchemaName $Object.schema_name
        $synonym = $synonymsByID[$Object.object_id]

        if( $synonym.target_object_id -and $synonym.target_object_id -ne $synonym.object_id )
        {
            Export-Object -ObjectID $synonym.target_object_id
        }

        if( $synonym.database_name -and $synonym.database_name -ne $Database )
        {
            Write-Warning -Message ('Unable to export SYNONYM {0}.{1}: it depends on external object [{2}].[{3}].[{4}].' -f $Object.schema_name,$Object.name,$synonym.database_name,$synonym.schema_name,$synonym.object_name)
            $exportedObjects[$Object.object_id] = $true
            return
        }

        $targetDBName = ''
        if( $synonym.database_name )
        {
            $targetDBName = ' -TargetDatabaseName ''{0}''' -f $synonym.database_name
        }

        $targetSchemaName = ''
        if( $synonym.schema_name )
        {
            $targetSchemaName = ' -TargetSchemaName ''{0}''' -f $synonym.schema_name
        }

        Write-ExportingMessage -Schema $Object.schema_name -Name $Object.name -Type Synonym
        '    Add-Synonym{0} -Name ''{1}''{2}{3} -TargetObjectName ''{4}''' -f $schema,$Object.name,$targetDBName,$targetSchemaName,$synonym.object_name
        Push-PopOperation ('Remove-Synonym{0} -Name ''{1}''' -f $schema,$Object.name)
        $exportedObjects[$Object.object_id] = $true
    }

    function Export-Table
    {
        param(
            [Parameter(Mandatory)]
            [object]
            $Object
        )

        $schema = ConvertTo-SchemaParameter -SchemaName $Object.schema_name

        $description = $Object.description
        if( $description )
        {
            $description = ' -Description ''{0}''' -f ($description -replace '''','''''')
        }

        Write-ExportingMessage -Schema $Object.schema_name -Name $Object.name -Type Table
        '    Add-Table{0} -Name ''{1}''{2} -Column {{' -f $schema,$object.object_name,$description
        Export-Column -TableID $object.object_id
        '    }'

        $exportedObjects[$object.object_id] = $true

        Export-PrimaryKey -TableID $Object.object_id -ForTable
        Export-DefaultConstraint -TableID $Object.object_id -ForTable
        Export-CheckConstraint -TableID $Object.object_id -ForTable
        Export-Index -TableID $Object.object_id -ForTable
        Export-UniqueKey -TableID $Object.object_id -ForTable
        Export-Trigger -TableID $Object.object_id -ForTable

        # Do this last because table objects can reference other objects and those would need to get removed before the table
        Push-PopOperation ('Remove-Table{0} -Name ''{1}''' -f $schema,$object.object_name)
    }

    $triggersQuery = '
-- TRIGGERS
select
    sys.triggers.name,
    schema_name(sys.objects.schema_id) as schema_name,
    sys.triggers.object_id,
    sys.triggers.parent_id
from
    sys.triggers
        join
    sys.objects
        on sys.triggers.object_id = sys.objects.object_id'
    function Export-Trigger
    {
        param(
            [Parameter(Mandatory,ParameterSetName='ByTrigger')]
            [object]
            $Object,

            [Parameter(Mandatory,ParameterSetName='ByTable')]
            [int]
            $TableID,

            [Switch]
            $ForTable
        )

        if( $PSCmdlet.ParameterSetName -eq 'ByTable' )
        {
            foreach( $object in $triggersByTable[$TableID] )
            {
                Export-Trigger -Object $object -ForTable:$ForTable
            }
            return
        }

        if( -not $ForTable )
        {
            Export-Object -ObjectID $Object.parent_object_id
        }

        if( $exportedObjects.ContainsKey($Object.object_id) )
        {
            return
        }

        Export-DependentObject -ObjectID $Object.object_id

        $schema = ConvertTo-SchemaParameter -SchemaName $object.schema_name
        $trigger = Get-ModuleDefinition -ObjectID $Object.object_id
        $createPreambleRegex = '^create\s+trigger\s+\[{0}\]\.\[{1}\]\s+' -f [regex]::Escape($Object.schema_name),[regex]::Escape($Object.name)
        Write-ExportingMessage -Schema $Object.schema_name -Name $Object.name -Type Trigger
        if( $trigger -match $createPreambleRegex )
        {
            $trigger = $trigger -replace $createPreambleRegex,''
            '    Add-Trigger{0} -Name ''{1}'' -Definition @''{2}{3}{2}''@' -f $schema,$Object.name,[Environment]::NewLine,$trigger
        }
        else
        {
            '    Invoke-Ddl -Query @''{0}{1}{0}''@' -f [Environment]::NewLine,$trigger
        }
        if( -not $ForTable )
        {
            Push-PopOperation ('Remove-Trigger{0} -Name ''{1}''' -f $schema,$Object.name)
        }
        $exportedObjects[$Object.object_id] = $true
    }

    $uniqueKeysQuery = '
-- UNIQUE KEYS
select
    sys.key_constraints.name,
    schema_name(sys.key_constraints.schema_id) as schema_name,
    sys.key_constraints.object_id,
    sys.tables.name as parent_object_name,
    sys.key_constraints.parent_object_id,
    sys.indexes.type_desc
from
    sys.key_constraints
        join
    sys.tables
            on sys.key_constraints.parent_object_id = sys.tables.object_id
        join
    sys.indexes
            on sys.indexes.object_id = sys.tables.object_id
			and sys.key_constraints.unique_index_id = sys.indexes.index_id
where
    sys.key_constraints.type = ''UQ'''

    $uniqueKeysColumnsQuery = '
-- UNIQUE KEY COLUMNS
select 
    sys.key_constraints.object_id,
    sys.columns.name
from 
	sys.key_constraints 
		join
	sys.indexes
			on sys.key_constraints.parent_object_id = sys.indexes.object_id
			and sys.key_constraints.unique_index_id = sys.indexes.index_id
		join 
	sys.index_columns 
			on sys.indexes.object_id = sys.index_columns.object_id 
			and sys.indexes.index_id = sys.index_columns.index_id 
		join
	sys.columns
			on sys.indexes.object_id = sys.columns.object_id
			and sys.index_columns.column_id = sys.columns.column_id
where 
    sys.key_constraints.type = ''UQ'''
    function Export-UniqueKey
    {
        param(
            [Parameter(Mandatory,ParameterSetName='ByKey')]
            [object]
            $Object,

            [Parameter(Mandatory,ParameterSetName='ForTable')]
            [int]
            $TableID,

            [Switch]
            $ForTable
        )

        if( $PSCmdlet.ParameterSetName -eq 'ForTable' )
        {
            foreach( $object in $uniqueKeysByTable[$TableID] )
            {
                Export-UniqueKey -Object $object -ForTable:$ForTable
            }
            return
        }

        if( -not $ForTable )
        {
            Export-Object -ObjectID $Object.parent_object_id
        }

        if( $exportedObjects.ContainsKey($Object.object_id) )
        {
            return
        }

        Export-DependentObject -ObjectID $Object.object_id

        $uniqueKey = $uniqueKeysByID[$Object.object_id]

        $columns = $uniqueKeyColumnsByObjectID[$Object.object_id]
        $columnNames = $columns | Select-Object -ExpandProperty 'name'
        $clustered = ''
        if( $uniqueKey.type_desc -eq 'CLUSTERED' )
        {
            $clustered = ' -Clustered'
        }
        $schema = ConvertTo-SchemaParameter -SchemaName $Object.schema_name
        Write-ExportingMessage -Schema $Object.schema_name -Name $Object.name -Type UniqueKey
        '    Add-UniqueKey{0} -TableName ''{1}'' -ColumnName ''{2}''{3} -Name ''{4}''' -f $schema,$Object.parent_object_name,($columnNames -join ''','''),$clustered,$Object.name
        if( -not $ForTable )
        {
            Push-PopOperation ('Remove-UniqueKey{0} -TableName ''{1}'' -Name ''{2}''' -f $schema,$Object.parent_object_name,$Object.name)
        }
        $exportedObjects[$Object.object_id] = $true
    }

    function Export-UserDefinedFunction
    {
        param(
            [Parameter(Mandatory)]
            [object]
            $Object
        )

        Export-DependentObject -ObjectID $Object.object_id

        $schema = ConvertTo-SchemaParameter -SchemaName $object.schema_name
        $function = Get-ModuleDefinition -ObjectID $Object.object_id
        $createPreambleRegex = '^create\s+function\s+\[{0}\]\.\[{1}\]\s+' -f [regex]::Escape($Object.schema_name),[regex]::Escape($Object.name)
        Write-ExportingMessage -Schema $Object.schema_name -Name $Object.name -Type Function
        if( $function -match $createPreambleRegex )
        {
            $function = $function -replace $createPreambleRegex,''
            '    Add-UserDefinedFunction{0} -Name ''{1}'' -Definition @''{2}{3}{2}''@' -f $schema,$Object.name,[Environment]::NewLine,$function
        }
        else
        {
            '    Invoke-Ddl -Query @''{0}{1}{0}''@' -f [Environment]::NewLine,$function
        }
        Push-PopOperation ('Remove-UserDefinedFunction{0} -Name ''{1}''' -f $schema,$Object.name)
        $exportedObjects[$Object.object_id] = $true
    }

    function Export-View
    {
        param(
            [Parameter(Mandatory)]
            [object]
            $Object
        )

        Export-DependentObject -ObjectID $Object.object_id

        $schema = ConvertTo-SchemaParameter -SchemaName $object.schema_name
        $query = 'select definition from sys.sql_modules where object_id = @view_id'
        $view = Get-ModuleDefinition -ObjectID $Object.object_id
        $createPreambleRegex = '^CREATE\s+view\s+\[{0}\]\.\[{1}\]\s+' -f [regex]::Escape($Object.schema_name),[regex]::Escape($Object.name)
        Write-ExportingMessage -Schema $Object.schema_name -Name $Object.name -Type View
        if( $view -match $createPreambleRegex )
        {
            $description = $Object.description
            if( $description )
            {
                $description = ' -Description ''{0}''' -f ($description -replace '''','''''')
            }
    
            $view = $view -replace $createPreambleRegex,''
            '    Add-View{0} -Name ''{1}''{2} -Definition @''{3}{4}{3}''@' -f $schema,$Object.name,$description,[Environment]::NewLine,$view

            # Get view's columns that have extended properties
            $viewColumns = Invoke-Query -Query $columnsQuery | Where-Object { $_.object_id -eq $Object.object_id -and $_.description }
            foreach( $column in $viewColumns )
            {
                $colDescription = ' -Description ''{0}''' -f ($column.description -replace '''','''''')
                '    Add-ExtendedProperty -SchemaName ''{0}'' -ViewName ''{1}'' -ColumnName ''{2}'' -Value {3}' -f $Object.schema_name,$Object.object_name,$column.column_name,$colDescription
            }
        }
        else
        {
            '    Invoke-Ddl -Query @''{0}{1}{0}''@' -f [Environment]::NewLine,$view
        }
        Push-PopOperation ('Remove-View{0} -Name ''{1}''' -f $schema,$Object.name)
        $exportedObjects[$Object.object_id] = $true
    }

    $xmlSchemaQuery = '
select 
    schema_name(schema_id) as schema_name,
    name,
	xml_collection_id,
	XML_SCHEMA_NAMESPACE(schema_name(schema_id),sys.xml_schema_collections.name) as xml_schema
from 
	sys.xml_schema_collections
where 
	sys.xml_schema_collections.name != ''sys'''
    function Export-XmlSchema
    {
        param(
            [Parameter(Mandatory)]
            [int]
            $ID
        )

        if( $exportedXmlSchemas.ContainsKey($ID) )
        {
            return
        }

        if( $ExcludeType -contains 'XmlSchema' )
        {
            return
        }

        $xmlSchema = $xmlSchemasByID[$ID]

        Write-ExportingMessage -SchemaName $xmlSchema.schema_name -Name $xmlSchema.name -Type XmlSchema
        '    Invoke-Ddl @'''
        'create xml schema collection [{0}].[{1}] as' -f $xmlSchema.schema_name,$xmlSchema.name
        'N'''
        $xmlschema.xml_schema
        ''''
        '''@'
        Push-PopOperation ('Invoke-Ddl ''drop xml schema collection [{0}].[{1}]''' -f $xmlSchema.schema_name,$xmlSchema.name)
        $exportedXmlSchemas[$ID] = $true
    }

    function Push-PopOperation
    {
        param(
            [Parameter(Mandatory)]
            $InputObject
        )

        if( -not ($popsHash.ContainsKey($InputObject)) )
        {
            $pops.Push($InputObject)
            $popsHash[$InputObject] = $true
        }
    }

    $objectTypesToExclude = @()
    if( $ExcludeType )
    {
        $objectTypesToExclude = $ExcludeType | ForEach-Object { $exclusionTypeMap[$_] }
    }
    function Test-SkipObject
    {
        param(
            [Parameter(Mandatory)]
            [string]
            $SchemaName,

            [Parameter(Mandatory)]
            [string]
            $Name,

            [string]
            $Type
        )

        if( -not $Include -and -not $ExcludeType -and -not $Exclude )
        {
            return $false
        }

        $fullName = '{0}.{1}' -f $SchemaName,$Name

        if( $Type )
        {
            if( $objectTypesToExclude -contains $Type )
            {
                Write-Debug ('Skipping   EXCLUDED TYPE      {0}  {1}' -f $fullName,$Type)
                return $true
            }
        }

        if( $Include )
        {
            $skip = $true
            foreach( $filter in $Include )
            {
                if( $fullName -like $filter )
                {
                    $skip = $false
                    break
                }
            }
            if( $skip )
            {
                return $true
            }
        }

        if( $Exclude )
        {
            foreach( $filter in $Exclude )
            {
                if( $fullName -like $filter )
                {
                    return $true
                }
            }
        }

        return $false
    }

    function Write-ExportingMessage
    {
        [CmdletBinding(DefaultParameterSetName='Schema')]
        param(
            [Parameter(Mandatory)]
            [string]
            $SchemaName,

            [Parameter(Mandatory,ParameterSetName='NotSchema')]
            [string]
            $Name,

            [Parameter(Mandatory)]
            [ValidateSet('Table','View','DefaultConstraint','StoredProcedure','Synonym','ForeignKey','CheckConstraint','PrimaryKey','Trigger','Function','Index','DataType','Schema','UniqueKey','XmlSchema')]
            [string]
            $Type
        )

        $objectName = $SchemaName
        if( $Name )
        {
            $objectName = '{0}.{1}' -f $objectName,$Name
        }

        $message = '{0,-17}  {1}{2}' -f $Type,('  ' * $indentLevel),$objectName
        $timer.CurrentOperation = $message
        $timer.ExportCount += 1
        Write-Verbose -Message $message
    }

    $activity = 'Exporting migrations from {0}.{1}' -f $SqlServerName,$Database
    $writeProgress = [Environment]::UserInteractive
    if( $NoProgress )
    {
        $writeProgress = $false
    }
    $event = $null

    Connect-Database -SqlServerName $SqlServerName -Database $Database -ErrorAction Stop | Out-Null
    try
    {
        #region QUERIES
        # OBJECTS
        $objects = Invoke-Query -Query $objectsQuery
        $objects | ForEach-Object { $objectsByID[$_.object_id] = $_ }
        $objects | Group-Object -Property 'parent_object_id' | ForEach-Object { $objectsByParentID[[int]$_.Name] = $_.Group }
        $objectTypes = $objects | Select-Object -ExpandProperty 'type_desc' | Select-Object -Unique

        # CHECK CONSTRAINTS
        if( $objectTypes -contains 'CHECK_CONSTRAINT' )
        {
            $checkConstraints = Invoke-Query -Query $checkConstraintsQuery
            $checkConstraints | ForEach-Object { $checkConstraintsByID[$_.object_id] = $_ }
        }

        # DATA TYPES
        $dataTypes = Invoke-Query -Query $dataTypesQuery

        # COLUMNS
        if( $objectTypes -contains 'USER_TABLE' -or $dataTypes )
        {
            $columns = Invoke-Query -Query $columnsQuery
            $columns | Group-Object -Property 'object_id' | ForEach-Object { $columnsByTable[[int]$_.Name] = $_.Group }
        }

        # DEFAULT CONSTRAINTS
        if( $objectTypes -contains 'DEFAULT_CONSTRAINT' )
        {
            $defaultConstraints = Invoke-Query -Query $defaultConstraintsQuery #-Parameter @{ '@object_id' = $constraintObject.object_id }
            $defaultConstraints | ForEach-Object { $defaultConstraintsByID[$_.object_id] = $_ }
        }

        # FOREIGN KEYS
        if( $objectTypes -contains 'FOREIGN_KEY_CONSTRAINT' )
        {
            $foreignKeys = Invoke-Query -Query $foreignKeysQuery
            $foreignKeys | ForEach-Object { $foreignKeysByID[$_.object_id] = $_ }

            # FOREIGN KEY COLUMNS
            $foreignKeyColumns = Invoke-Query -Query $foreignKeyColumnsQuery
            $foreignKeyColumns | Group-Object -Property 'constraint_object_id' | ForEach-Object { $foreignKeyColumnsByObjectID[[int]$_.Name] = $_.Group }
        }

        # INDEXES
        if( $objectTypes -contains 'USER_TABLE' )
        {
            $indexes = Invoke-Query -Query $indexesQuery
            $indexes | Group-Object -Property 'object_id' | ForEach-Object { $indexesByObjectID[[int]$_.Name] = $_.Group }

            # INDEX COLUMNS
            $indexColumns = Invoke-Query -Query $indexesColumnsQuery
            $indexColumns | Group-Object -Property 'object_id' | ForEach-Object { $indexColumnsByObjectID[[int]$_.Name] = $_.Group }
        }

        if( $objectTypes -contains 'PRIMARY_KEY_CONSTRAINT' )
        {
            $primaryKeys = Invoke-Query -Query $primaryKeysQuery
            $primaryKeys | ForEach-Object { $primaryKeysByID[$_.object_id] = $_ }

            $primaryKeyColumns = Invoke-Query -Query $primaryKeyColumnsQuery
            $primaryKeyColumns | Group-Object -Property 'object_id' | ForEach-Object { $primaryKeyColumnsByObjectID[[int]$_.Name] = $_.Group }
        }

        # SCHEMAS
        if( ($objects | Where-Object { $_.schema_name -ne 'dbo' }) -or ($dataTypes | Where-Object { $_.schema_name -ne 'dbo' }) )
        {
            $schemas = Invoke-Query -Query $schemasQuery
            $schemas | ForEach-Object { $schemasByName[$_.name] = $_ }
        }

        # MODULES/PROGRAMMABILITY
        if( $objectTypes -contains 'SQL_INLINE_TABLE_VALUED_FUNCTION' -or $objectTypes -contains 'SQL_SCALAR_FUNCTION' -or $objectTypes -contains 'SQL_STORED_PROCEDURE' -or $objectTypes -contains 'SQL_TABLE_VALUED_FUNCTION' -or $objectTypes -contains 'SQL_TRIGGER' -or $objectTypes -contains 'VIEW' )
        {
            $query = 'select object_id, definition from sys.sql_modules'
            $modules = Invoke-Query -Query $query
            $modules | ForEach-Object { $modulesByID[$_.object_id] = $_ }
        }

        # SYNONYMS
        if( $objectTypes -contains 'SYNONYM' )
        {
            $synonyms = Invoke-Query -Query $synonymsQuery
            $synonyms | ForEach-Object { $synonymsByID[$_.object_id] = $_ }
        }

        # TRIGGERS
        if( $objectTypes -contains 'SQL_TRIGGER' )
        {
            $triggers = Invoke-Query -Query $triggersQuery
            $triggers | ForEach-Object { $triggersByID[$_.object_id] = $_ }        
            $triggers | Group-Object -Property 'parent_id' | ForEach-Object { $triggersByTable[[int]$_.Name] = $_.Group }
        }

        if( $objectTypes -contains 'UNIQUE_CONSTRAINT' )
        {
            # UNIQUE KEYS
            $uniqueKeys =  Invoke-Query -Query $uniqueKeysQuery
            $uniqueKeys | ForEach-Object { $uniqueKeysByID[$_.object_id] = $_ }
            $uniqueKeys | Group-Object -Property 'parent_object_id' | ForEach-Object { $uniqueKeysByTable[[int]$_.Name] = $_.Group }
        
            # UNIQUE KEY COLUMNS
            $uniqueKeyColumns = Invoke-Query -Query $uniqueKeysColumnsQuery
            $uniqueKeyColumns | Group-Object -Property 'object_id' | ForEach-Object { $uniqueKeyColumnsByObjectID[[int]$_.Name] = $_.Group }
        }

        if( $columns | Where-Object { $_.xml_collection_id } )
        {
            $query = '
select 
	sys.columns.object_id,
	sys.columns.xml_collection_id
from 
	sys.columns 
		join
	sys.types
			on sys.columns.user_type_id=sys.types.user_type_id
			and sys.columns.system_type_id=sys.types.system_type_id
where 
	sys.types.name = ''xml'' and
	sys.columns.xml_collection_id != 0
'
            $objectsWithXmlSchemas = Invoke-Query -Query $query
            $objectsWithXmlSchemas | Group-Object -Property 'object_id' | ForEach-Object { $xmlSchemaDependencies[[int]$_.Name] = $_.Group | Select-Object -ExpandProperty 'xml_collection_id' | Select-Object -Unique }

            $xmlSchemas = Invoke-Query -Query $xmlSchemaQuery
            $xmlSchemas | ForEach-Object { $xmlSchemasByID[$_.xml_collection_id] = $_ }
        }
        #endregion

        $sysDatabases = @( 'master', 'model', 'msdb', 'tempdb' )
        $query = 'select * from sys.sql_expression_dependencies'
        foreach( $row in (Invoke-Query -Query $query) )
        {
            $externalName = '[{0}]' -f $row.referenced_entity_name
            if( $row.referenced_schema_name )
            {
                $externalName = '[{0}].{1}' -f $row.referenced_schema_name,$externalName
            }
            if( $row.referenced_database_name )
            {
                # Allow references to system databases.
                if( $row.referenced_database_name -in $sysDatabases )
                {
                    continue
                }

                $externalName = '[{0}].{1}' -f $row.referenced_database_name,$externalName
            }
            if( $row.referenced_server_name )
            {
                $externalName = '[{0}].{1}' -f $row.referenced_server_name,$externalName
            }

            if( $row.referenced_server_name -or ($row.referenced_database_name -ne $null -and $row.referenced_database_name -ne $Database) )
            {
                $externalDependencies[$row.referencing_id] = $externalName
            }
            else
            {
                if( -not $dependencies.ContainsKey($row.referencing_id) )
                {
                    $dependencies[$row.referencing_id] = @{}
                }
                if( $row.referenced_id -ne $null -and $row.referenced_id -ne $row.referencing_id )
                {
                    $dependencies[$row.referencing_id][$row.referenced_id] = $externalName
                }
            }
        }

        $totalOperationCount = & {
                                    $objects
                                    $schemas
                                    $indexes
                                    $dataTypes
                                } | 
            Measure-Object | 
            Select-Object -ExpandProperty 'Count'

        if( $writeProgress )
        {
            Write-Progress -Activity $activity 
        }

        $timer | 
            Add-Member -Name 'ExportCount' -Value 0 -MemberType NoteProperty -PassThru |
            Add-Member -MemberType NoteProperty -Name 'Activity' -Value $activity -PassThru |
            Add-Member -MemberType NoteProperty -Name 'CurrentOperation' -Value '' -PassThru |
            Add-Member -MemberType NoteProperty -Name 'TotalCount' -Value $totalOperationCount
        
        if( $writeProgress )
        {
            # Write-Progress is *expensive*. Only do it if the user is interactive and only every 1/10th of a second.
            $event = Register-ObjectEvent -InputObject $timer -EventName 'Elapsed' -Action {
                param(
                    $Timer,
                    $EventArgs
                )
                Write-Progress -Activity $Timer.Activity -CurrentOperation $Timer.CurrentOperation -PercentComplete (($Timer.ExportCount/$Timer.TotalCount) * 100)
            }
            $timer.Enabled = $true
            $timer.Start()
        }

        'function Push-Migration'
        '{'
            Export-DataType
            Export-Object
            Export-Index
        '}'
        ''
        'function Pop-Migration'
        '{'
            $pops | ForEach-Object { '    {0}' -f $_ }
        '}'
    }
    finally
    {
        if( $writeProgress )
        {
            $timer.Stop()
            if( $event )
            {
                Unregister-Event -SourceIdentifier $event.Name
            }
            Write-Progress -Activity $activity -PercentComplete 99
            Write-Progress -Activity $activity -Completed
        }
        Disconnect-Database
    }
}
