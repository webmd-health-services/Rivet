
function Export-Migration
{
    <#
    .SYNOPSIS
    Exports objects from a database as Rivet migrations.

    .DESCRIPTION
    The `Export-Migration` function exports database objects as Rivet migrations.
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
        $Include
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    
    $pops = New-Object 'Collections.Generic.Stack[string]'
    $exportedObjects = @{ }
    $exportedSchemas = @{ 
                            'dbo' = $true;
                            'guest' = $true;
                            'sys' = $true;
                            'INFORMATION_SCHEMA' = $true;
                        }

    function ConvertTo-SchemaParameter
    {
        param(
            [string]
            $SchemaName
        )

        $parameter = ''
        if( $SchemaName -and $SchemaName -ne 'dbo' )
        {
            $parameter = ' -SchemaName ''{0}''' -f $SchemaName
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

        $query = 'select sys.objects.name as object_name, * from sys.objects where parent_object_id = @table_id and type = @type'
        return Invoke-Query -Query $query -Parameter @{ '@table_id' = $TableID; '@type' = $Type }
    }

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
            $SkipPop
        )

        if( $TableID )
        {
            $Object = Get-ChildObject -TableID $TableID -Type 'C'
            if( -not $Object )
            {
                return
            }
        }

        foreach( $constraintObject in $Object )
        {
            if( $exportedObjects.ContainsKey($Object.object_id) )
            {
                continue
            }

            $query = 'select 
    schema_name(sys.tables.schema_id) as schema_name, sys.tables.name as table_name, sys.check_constraints.name as name, definition 
from 
    sys.check_constraints 
    join 
    sys.tables 
        on sys.check_constraints.parent_object_id = sys.tables.object_id
where
    sys.check_constraints.object_id = @object_id'
            $constraint = Invoke-Query -Query $query -Parameter @{ '@object_id' = $constraintObject.object_id }
            $schema = ConvertTo-SchemaParameter -SchemaName $constraint.schema_name
            '    Add-CheckConstraint{0} -TableName ''{1}'' -Name ''{2}'' -Expression ''{3}''' -f $schema,$constraint.table_name,$constraint.name,$constraint.definition
            if( -not $SkipPop )
            {
                Push-PopOperation ('    Remove-CheckConstraint{0} -TableName ''{1}'' -Name ''{2}''' -f $schema,$constraint.table_name,$constraint.name)
            }
            $exportedObjects[$constraintObject.object_id] = $true
        }
    }

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
            $SkipPop
        )

        if( $TableID )
        {
            $Object = Get-ChildObject -TableID $TableID -Type 'D'
            if( -not $Object )
            {
                return
            }
        }

        foreach( $constraintObject in $Object )
        {
            if( $exportedObjects.ContainsKey($Object.object_id) )
            {
                continue
            }

            $query = '
select 
    schema_name(sys.tables.schema_id) as schema_name, sys.tables.name as table_name, sys.default_constraints.name as name, sys.columns.name as column_name, definition 
from 
    sys.objects 
    join sys.tables 
        on sys.objects.parent_object_id = sys.tables.object_id
    join sys.schemas
        on sys.schemas.schema_id = sys.tables.schema_id
    join sys.default_constraints
        on sys.default_constraints.object_id = sys.objects.object_id
	join sys.columns 
		on sys.columns.object_id = sys.default_constraints.parent_object_id
		and sys.columns.column_id = sys.default_constraints.parent_column_id
where
    sys.default_constraints.object_id = @object_id'
            $constraint = Invoke-Query -Query $query -Parameter @{ '@object_id' = $constraintObject.object_id }
            $schema = ConvertTo-SchemaParameter -SchemaName $constraint.schema_name
            '    Add-DefaultConstraint{0} -TableName ''{1}'' -ColumnName ''{2}'' -Name ''{3}'' -Expression ''{4}''' -f $schema,$constraint.table_name,$constraint.column_name,$constraint.name,$constraint.definition
            if( -not $SkipPop )
            {
                Push-PopOperation ('    Remove-DefaultConstraint{0} -TableName ''{1}'' -Name ''{2}''' -f $schema,$constraint.table_name,$constraint.name)
            }
            $exportedObjects[$constraintObject.object_id] = $true
        }
    }

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
            $SkipPop
        )

        if( $TableID )
        {
            $Object = Get-ChildObject -TableID $TableID -Type 'PK'
            if( -not $Object )
            {
                return
            }
        }

        if( $exportedObjects.ContainsKey($Object.object_id) )
        {
            return
        }

        $query = 'select 
	sys.schemas.name as schema_name, sys.tables.name as table_name, sys.columns.name as column_name
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
    sys.objects.object_id = @object_id and
	sys.objects.type = ''PK'' and
	sys.indexes.is_primary_key = 1'
        $columns = Invoke-Query -Query $query -Parameter @{ '@object_id' = $Object.object_id }
        $primaryKey = $columns | Select-Object -First 1
        if( $primaryKey )
        {
            $schema = ConvertTo-SchemaParameter -SchemaName $primaryKey.schema_name
            $columnNames = $columns | Select-Object -ExpandProperty 'column_name'
            '    Add-PrimaryKey{0} -TableName ''{1}'' -ColumnName ''{2}'' -Name ''{3}''' -f $schema,$primaryKey.table_name,($columnNames -join ''','''),$object.object_name
            if( -not $SkipPop )
            {
                Push-PopOperation ('Remove-PrimaryKey{0} -TableName ''{1}'' -Name ''{2}''' -f $schema,$primaryKey.table_name,$object.object_name)
            }
            $exportedObjects[$Object.object_id] = $true
        }
    }

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

        $query = 'select sys.schemas.name as name, sys.sysusers.name as owner from sys.schemas join sys.sysusers on sys.schemas.principal_id = sys.sysusers.uid where sys.schemas.name = @schema_name'
        $schema = Invoke-Query -Query $query -Parameter @{ '@schema_name' = $Name }
        if( $schema )
        {
            '    Add-Schema -Name ''{0}'' -Owner ''{1}''' -f $schema.name,$schema.owner
            ''
            $exportedSchemas[$schema.name] = $true
            Push-PopOperation ('Remove-Schema -Name ''{0}''' -f $schema.name)
        }
    }

    function Export-StoredProcedure
    {
        param(
            [Parameter(Mandatory)]
            [object]
            $Object
        )

        $query = 'select definition from sys.sql_modules where object_id = @object_id'
        $definition = Invoke-Query -Query $query -Parameter @{ '@object_id' = $Object.object_id } -AsScalar

        $schema = ConvertTo-SchemaParameter -SchemaName $Object.schema_name
        '    Invoke-Ddl -Query @''{0}{1}''@' -f $definition,[Environment]::NewLine
        Push-PopOperation ('Remove-StoredProcedure{0} -Name ''{1}''' -f $schema,$Object.object_name)
    }

    function Export-Table
    {
        param(
            [Parameter(Mandatory)]
            [object]
            $Object
        )

        $schema = ConvertTo-SchemaParameter -SchemaName $Object.schema_name

        Push-PopOperation ('Remove-Table{0} -Name ''{1}''' -f $schema,$object.object_name)

        '    Add-Table{0} -Name ''{1}'' -Column {{' -f $schema,$object.object_name

        $query = 'select sys.types.name as type_name, sys.columns.name as column_name, sys.types.collation_name as type_collation_name, sys.columns.max_length as column_max_length, * from sys.columns inner join sys.types on columns.user_type_id = sys.types.user_type_id  where object_id = @object_id'
        foreach( $column in (Invoke-Query -Query $query -Parameter @{ '@object_id' = $object.object_id }) )
        {
            $notNull = ''
            if( $column.is_nullable )
            {
                $notNull = ' -NotNull'
            }
            $size = ''
            if( $column.type_collation_name )
            {
                $maxLength = $column.column_max_length
                if( $column.type_name -like 'n*' )
                {
                    $maxLength = $maxLength / 2
                }
                $size = ' -Size {0}' -f $maxLength
            }
            '        {0} ''{1}''{2}{3}' -f $column.type_name,$column.column_name,$size,$notNull
        }

        '    }'

        Export-PrimaryKey -TableID $Object.object_id -SkipPop
        Export-DefaultConstraint -TableID $Object.object_id -SkipPop
        Export-CheckConstraint -TableID $Object.object_id -SkipPop
    }

    function Push-PopOperation
    {
        param(
            [Parameter(Mandatory)]
            $InputObject
        )

        if( -not ($pops | Where-Object { $_ -eq $InputObject }) )
        {
            $pops.Push($InputObject)
        }
    }

    Connect-Database -SqlServerName $SqlServerName -Database $Database -ErrorAction Stop | Out-Null
    try
    {
        'function Push-Migration'
        '{'
            $query = 'select sys.schemas.name as schema_name, sys.objects.name as object_name, sys.schemas.name + ''.'' + sys.objects.name as full_name, * from sys.objects join sys.schemas on sys.objects.schema_id = sys.schemas.schema_id where is_ms_shipped = 0'
            foreach( $object in (Invoke-Query -Query $query) )
            {
                if( $exportedObjects.ContainsKey($object.object_id) )
                {
                    Write-Debug ('Skipping   ALREADY EXPORTED  {0}' -f $object.full_name)
                    continue
                }

                if( $Include -and -not ($Include | Where-Object { $object.full_name -like $_ }) )
                {
                    Write-Debug ('Skipping   NOT SELECTED      {0}' -f $object.full_name)
                    continue
                }

                if( $object.schema_name -eq 'rivet' )
                {
                    continue
                }

                Export-Schema -Name $object.schema_name

                Write-Verbose ('Exporting  {0}' -f $object.full_name)
                switch ($object.type_desc)
                {
                    'CHECK_CONSTRAINT'
                    {
                        Export-CheckConstraint -Object $object
                    }
                    'DEFAULT_CONSTRAINT'
                    {
                        Export-DefaultConstraint -Object $object
                    }
                    'PRIMARY_KEY_CONSTRAINT'
                    {
                        Export-PrimaryKey -Object $object
                    }
                    'SQL_STORED_PROCEDURE'
                    {
                        Export-StoredProcedure -Object $object
                    }
                    'USER_TABLE'
                    {
                        Export-Table -Object $object
                    }
                    default
                    {
                        Write-Error -Message ('Unable to export object "{0}": unsupported object type "{1}".' -f $object.full_name,$object.type_desc)
                    }
                }
                $exportedObjects[$object.object_id] = $true
                ''
            }
        '}'
        ''
        'function Pop-Migration'
        '{'
            $pops | ForEach-Object { '    {0}' -f $_ }
        '}'
    }
    finally
    {
        Disconnect-Database
    }
}
