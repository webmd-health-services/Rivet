
function Update-CodeObjectMetadata
{
    <#
    .SYNOPSIS
    Updates the metadata for a stored procedure, user-defined function, view, trigger, etc.

    .DESCRIPTION
    SQL Server has a stored procedure, `sys.sp_refreshsqlmodule`, which will refresh/update a the objects used by a code object (stored procedure, user-defined function, view, etc.) if that object has changed since the code object was created.

    .LINK
    http://technet.microsoft.com/en-us/library/bb326754.aspx

    .EXAMPLE
    Update-CodeObjectMetadata 'GetUsers'

    Demonstrates how to update the `GetUsers` code object.

    .EXAMPLE
    Update-CodeObjectMetadata -SchemaName 'example' 'GetUsers'

    Demonstrates how to update a code object in a custom schema, in this case the `example` schema.
    #>
    [CmdletBinding(DefaultParameterSetName='CodeObject')]
    param(
        [Parameter()]
        [string]
        # The code object's schema name.  Default is `dbo`.
        $SchemaName = 'dbo',

        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the code object.
        $Name,

        [Parameter(Mandatory=$true,ParameterSetName='DATABASE_DDL_TRIGGER')]
        [Switch]
        # The object is a database DDL trigger.
        $DatabaseDdlTrigger,

        [Parameter(Mandatory=$true,ParameterSetName='SERVER_DDL_TRIGGER')]
        [Switch]
        # The object is a server DDL trigger.
        $ServerDdlTrigger
    )

    Set-StrictMode -Version 'Latest'

    $namespace = $null
    if( $PSCmdlet.ParameterSetName -like '*_DDL_TRIGGER' )
    {
        $namespace = $PSCmdlet.ParameterSetName
    }
    $op = New-Object 'Rivet.Operations.UpdateCodeObjectMetadataOperation' $SchemaName,$Name,$namespace
    Write-Host (' ={0}.{1}' -f $SchemaName,$Name)
    [int]$result = Invoke-MigrationOperation -Operation $op -AsScalar

    if ($result -ne 0)
    {
        throw ("Failed to refresh {0}.{1}: error code {3}" -f $SchemaName,$Name,$result)
    }
}