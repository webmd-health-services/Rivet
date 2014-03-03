
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

    $type = Get-DataType -Name $Name -SchemaName $SchemaName
    Assert-NotNull $type ('Data type ''{0}.{1}'' not found.' -f $SchemaName,$Name)

    if( $PSBoundParameters.ContainsKey( 'BaseTypeName' ) )
    {
        if( $BaseTypeName -eq $null )
        {
            Assert-Null $type.base_type_name
        }
        else
        {
            Assert-Equal $BaseTypeName $type.base_type_name
        }
    }

    Assert-Equal $UserDefined $type.is_user_defined ('{0}.{1}.is_user_defined' -f $SchemaName,$Name)
    Assert-Equal (-not $NotNull) $type.is_nullable ('{0}.{1}.is_nullable' -f $SchemaName,$Name)
    Assert-Equal $AssemblyType $type.is_assembly_type ('{0}.{1}.is_assembly_type' -f $SchemaName,$Name)
    Assert-Equal $TableType $type.is_table_type ('{0}.{1}.is_table_type' -f $SchemaName,$Name)
}