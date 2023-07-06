
function Assert-DataType
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the data type.
        $Name,

        [string]
        # The schema of the data type.
        $SchemaName = 'dbo',

        [object]
        # The name of the type's base type.
        $BaseTypeName,

        [Switch]
        # Asserts the type is a user-defined data type.
        $UserDefined,

        [Switch]
        # Asserts the type is not nullable.
        $NotNull,

        [Switch]
        # Asserts the type is an assembly type.
        $AssemblyType,

        [Switch]
        # Asserts the type is a table type.
        $TableType
    )

    Set-StrictMode -Version 'Latest'

    $type = Get-DataType -Name $Name -SchemaName $SchemaName

    $type | Should -Not -BeNullOrEmpty -Because ('Data type ''{0}.{1}'' not found.' -f $SchemaName,$Name)

    if( $PSBoundParameters.ContainsKey( 'BaseTypeName' ) )
    {
        if ($null -eq $BaseTypeName)
        {
            $type.base_type_name | Should -BeNullOrEmpty
        }
        else
        {
            $type.base_type_name | Should -Be $BaseTypeName
        }
    }

    $type.is_user_defined | Should -Be $UserDefined -Because ('{0}.{1}.is_user_defined' -f $SchemaName,$Name)
    $type.is_nullable | Should -Be (-not $NotNull) -Because ('{0}.{1}.is_nullable' -f $SchemaName,$Name)
    $type.is_assembly_type | Should -Be $AssemblyType -Because ('{0}.{1}.is_assembly_type' -f $SchemaName,$Name)
    $type.is_table_type | Should -Be $TableType -Because ('{0}.{1}.is_table_type' -f $SchemaName,$Name)
}
