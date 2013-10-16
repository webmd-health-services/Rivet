function Add-DataType
{
    <#
    .SYNOPSIS
    Creates an alias or user-defined type.
    
    .DESCRIPTION
    There are three different user-defined data types. The first is an alias, from a name you choose to a system datatype.  The second is an assembly type, which uses a type stored in a .NET assembly.  The third is a table data type, which create a type for a table.
    
    .LINK
    Remove-DataType

    .LINK
    http://technet.microsoft.com/en-us/library/ms175007.aspx
    
    .EXAMPLE
    Add-DataType 'GUID' 'uniqueidentifier'
    
    Demonstrates how to create a new alias data type called `GUID` which aliases the system `uniqueidentifier`.
    
    .EXAMPLE
    Add-DataType 'Names' -AsTable { varchar 'Name' 50 } -TableConstraint 'primary key'
    
    Demonstrates how to create a new table-based data type.
    
    .EXAMPLE
    Add-DataType 'RivetDateTime' -AssemblyName 'Rivet' -ClassName 'Rivet.RivetDateTime'
    
    Demonstrates how to create a `RivetDateTime` type that references the `Rivet.RivetDateTime` class.  The `Rivet` assembly must first be registered using `create assembly`.
    #>

    [CmdletBinding(DefaultParameterSetName='From')]
    param(
        [Parameter()]
        [string]
        # The schema for the type. Default is `dbo`.
        $SchemaName = 'dbo',
        
        [Parameter(Mandatory=$true,Position=0)]
        [string]
        # The name of the type.
        $Name,
        
        [Parameter(Mandatory=$true,Position=1,ParameterSetName='From')]
        [string]
        # The system type to alias.
        $From,
        
        [Parameter(Mandatory=$true,ParameterSetName='Assembly')]
        [string]
        # The name of the assembly for the type's implementation.
        $AssemblyName,
        
        [Parameter(Mandatory=$true,ParameterSetName='Assembly')]
        [string]
        # The name of the type's class implementation.
        $ClassName,
        
        [Parameter(Mandatory=$true,ParameterSetName='AsTable')]
        [ScriptBlock]
        # A `ScriptBlock` which returns columns for the table.
        $AsTable,
        
        [Parameter(ParameterSetName='AsTable')]
        [string[]]
        # A list of table constraints for a table-based data type.
        $TableConstraint
    )

    if ($PsCmdlet.ParameterSetName -eq 'From')
    {
        $op = New-Object 'Rivet.Operations.AddDataTypeOperation' $SchemaName, $Name, $From
    }
    if ($PsCmdlet.ParameterSetName -eq 'Assembly')
    {
        $op = New-Object 'Rivet.Operations.AddDataTypeOperation' $SchemaName, $Name, $AssemblyName, $ClassName
    }
    if ($PsCmdlet.ParameterSetName -eq 'AsTable')
    {
        # Process Column Scriptblock -> Rivet.Column[]
        $columns = & $AsTable
        $op = New-Object 'Rivet.Operations.AddDataTypeOperation' $SchemaName, $Name, $columns, $TableConstraint
    }

    Write-Host (' +{0}.{1}' -f $SchemaName,$Name)
    Invoke-MigrationOperation -Operation $op

}
