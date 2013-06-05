
function Assert-Column
{
    param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]
        $Name,

        [Parameter(Position=1,Mandatory=$true)]
        [string]
        $DataType,

        [string]
        $Description,

        [Switch]
        $Max,

        [int]
        $Size,

        [int]
        $Precision,

        [int]
        $Scale,

        [Switch]
        $Sparse,

        [Switch]
        $NotNull,

        [int]
        $Seed,

        [int]
        $Increment,

        [Switch]
        $NotForReplication,

        [Switch]
        $RowGuidCol,

        [Switch]
        $Document,

        [Switch]
        $FileStream,

        [string]
        $Collation,

        [Object]
        $Default,

        [Parameter(Mandatory=$true)]
        $TableName,

        $TableSchema = 'dbo'
    )

    $query = @'
    select 
        ty.name type_name, c.*, ex.value MSDescription, dc.name default_constraint_name, dc.definition default_constraint, ic.seed_value, ic.increment_value, ic.is_not_for_replication
    from sys.columns c join 
        sys.tables t on c.object_id = t.object_id join 
        sys.schemas s on t.schema_id = s.schema_id join
        sys.types ty on c.user_type_id = ty.user_type_id left outer join
        sys.extended_properties ex on ex.major_id = c.object_id and ex.minor_id = c.column_id and OBJECTPROPERTY(c.object_id, 'IsMsShipped') = 0 and ex.name = 'MS_Description' left outer join
        sys.default_constraints dc on c.object_id = dc.parent_object_id and c.column_id = dc.parent_column_id left outer join
        sys.identity_columns ic on c.object_id = ic.object_id and c.column_id = ic.column_id
    where
        s.name = '{0}' and t.name = '{1}' and c.name = '{2}'
'@ -f $TableSchema, $TableName, $Name
    $column = Invoke-PstepTestQuery -Query $query -Connection $DatabaseConnection
    Assert-NotNull $column ('{0}.{1}: column {2} not found' -f $TableSchema,$TableName,$Name)

    Assert-Equal $DataType $column.type_name ('column {0} not expected type' -f $Name)
    
    if( $Max )
    {
        Assert-Equal -1 $column.max_length ('column {0} not max size' -f $Name)
    }

    if( $Size )
    {
        if( $column.type_name -like 'n*char' )
        {
            Assert-Equal $Size ($column.max_length / 2) ('column {0} not expected size' -f $Name)
        }
        else
        {
            Assert-Equal $Size $column.max_length ('column {0} not expected size' -f $Name)
        }
    }

    if( $Precision )
    {
        Assert-Equal $Precision $column.precision ('column {0} not expected precision' -f $Name)
    }

    if( $Scale )
    {
        Assert-Equal $Scale $column.scale ('column {0} not expected scale' -f $Name)
    }

    if( $NotNull )
    {
        Assert-False $column.is_nullable ('column {0} nullable' -f $Name)
    }
    else
    {
        Assert-True $column.is_nullable ('column {0} not nullable' -f $Name)
    }

    if( $PSBoundParameters.ContainsKey('Description') )
    {
        Assert-Equal $Description $column.MSDescription ('column {0} description not set' -f $Name)
    }

    if( $Default )
    {
        Assert-NotNull $column.default_constraint ('column {0} default constraint not created')
        $dfConstraintName = New-DefaultConstraintName -ColumnName $Name -TableName $TableName -TAbleSchema $TableSchema
        Assert-Equal $dfConstraintName $column.default_constraint_name ('column {0} default constraint name not set correctly' -f $Name)
        Assert-Match  $column.default_constraint ('{0}' -f ([Text.RegularExpressions.Regex]::Escape($Default))) ('column {0} default constraint not set' -f $Name)
    }

    if( $Seed -or $Increment )
    {
        Assert-True $column.is_identity ('column {0} not an identity' -f $Name)
        if( $Seed )
        {
            Assert-Equal $Seed $column.seed_value ('column {0} identity seed value not set' -f $Name)
        }

        if( $Increment )
        {
            Assert-Equal $Increment $column.increment_value ('column {0} identity increment value not set' -f $Name)
        }
    }

    if( $RowGuidCol )
    {
        Assert-True $column.is_rowguidcol ('column {0} rowguidcol flag not set' -f $Name)
    }

    if( $Document )
    {
        Assert-True $column.is_xml_document ('column {0} not an xml document' -f $Name)
    }

    if( $FileStream )
    {
        Assert-True $column.is_filestream ('column {0} not a filestream' -f $Name)
    }

    if( $Collation )
    {
        Assert-Equal $Collation $column.collation_name ('column {0} collation not set' -f $Name)
    }

    if( $Sparse )
    {
        Assert-True $column.is_sparse ('column {0} is not sparse' -f $Name)
    }

    if( $NotForReplication )
    {
        Assert-True $column.is_not_for_replication ('column {0} is a replicated identity' -f $Name)
    }
}
