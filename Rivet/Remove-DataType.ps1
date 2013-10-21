function Remove-DataType
{
    <#
    .SYNOPSIS
    Drops a user-defined datatype.
    
    .DESCRIPTION
    Handles all three datatypes: alias, CLR, and table.  If the datatype is in use, you'll get an error.  Make sure to remove/alter any objects that reference the type first.
    
    .LINK
    Add-DataType
    
    .LINK
    http://technet.microsoft.com/en-us/library/ms174407.aspx
    
    .EXAMPLE
    Remove-DataType 'GUID'
    
    Demonstrates how to remove the `GUID` user-defined data type.
    
    .EXAMPLE
    Remove-DataType -SchemaName 'rivet' 'GUID'
    
    Demonstrates how to remove a datatype in a schema other than `dbo`.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        # The name of the type's schema. Default is `dbo`.
        $SchemaName = 'dbo',
        
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the datatype to drop.
        $Name
    )

    $op = New-Object 'Rivet.Operations.RemoveDataTypeOperation' $SchemaName, $Name
    Write-Host (' -{0}.{1}' -f $SchemaName,$Name)
    Invoke-MigrationOperation -Operation $op
}