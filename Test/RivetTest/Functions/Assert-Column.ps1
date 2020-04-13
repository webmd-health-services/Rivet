
function Assert-Column
{
    param(
        [Parameter(Position=0,Mandatory=$true)]
        [string]
        $Name,

        [Parameter(Position=1,Mandatory=$true)]
        [string]
        $DataType,

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

        [Alias('TableSchema')]
        $SchemaName = 'dbo'
    )
    
    Set-StrictMode -Version Latest

    $column = Get-Column -SchemaName $SchemaName -TableName $TableName -Name $Name

    if( (Test-Pester) )
    {
        $column | Should -Not -BeNullOrEmpty

        $column.type_name | Should -Be $DataType
    
        if( $Max )
        {
            $column.max_length | Should -Be -1
        }

        if( $Size )
        {
            if( $column.type_name -like 'n*char' )
            {
                ($column.max_length / 2) | Should -Be $Size
            }
            else
            {
                $column.max_length | Should -Be $Size
            }
        }

        if( $Precision )
        {
            $column.precision | Should -Be $Precision
        }

        if( $Scale )
        {
            $column.scale | Should -Be $Scale
        }

        if( $NotNull )
        {
            $column.is_nullable | Should -BeFalse
        }
        else
        {
            $column.is_nullable | Should -BeTrue
        }

        if( $PSBoundParameters.ContainsKey('Description') )
        {
             $column.MSDescription | Should -Be $Description
        }

        if( $Default )
        {
            $column.default_constraint | Should -Not -BeNullOrEmpty
            $dfConstraintName = New-ConstraintName -SchemaName $SchemaName -TableName $TableName -ColumnName $Name -Default
            $column.default_constraint_name | Should -Be $dfConstraintName
            $column.default_constraint | Should -Match ('{0}' -f ([Text.RegularExpressions.Regex]::Escape($Default)))
        }

        if( $Seed -or $Increment )
        {
            $column.is_identity | Should -BeTrue
            if( $Seed )
            {
                $column.seed_value | Should -Be $Seed
            }

            if( $Increment )
            {
                $column.increment_value | Should -Be $Increment
            }
        }

        if( $RowGuidCol )
        {
            $column.is_rowguidcol | Should -BeTrue
        }
        else
        {
            $column.is_rowguidcol | Should -BeFalse
        }

        if( $Document )
        {
            $column.is_xml_document | Should -BeTrue
        }

        if( $FileStream )
        {
            $column.is_filestream | Should -BeTrue
        }

        if( $Collation )
        {
            $column.collation_name | Should -Be $Collation
        }

        if( $Sparse )
        {
            $column.is_sparse | Should -BeTrue
        }

        if( $NotForReplication )
        {
            $column.is_not_for_replication | Should -BeTrue
        }
    }
    else
    {
        Assert-NotNull $column ('{0}.{1}: column {2} not found' -f $SchemaName,$TableName,$Name)

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
            $dfConstraintName = New-ConstraintName -SchemaName $SchemaName -TableName $TableName -ColumnName $Name -Default
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
        else
        {
            Assert-False $column.is_rowguidcol ('column {0} rowguidcol flag set' -f $Name)
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
}
