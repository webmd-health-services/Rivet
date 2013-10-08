 function Add-Synonym
{
    <#
    .SYNOPSIS
    Creates a synonym.

    .DESCRIPTION
    SQL Server lets you create synonyms so you can reference an object with a different name, or reference an object in another database with a local name.
    
    .LINK
    http://technet.microsoft.com/en-us/library/ms177544.aspx
    
    .EXAMPLE
    Add-Synonym -Name 'Buzz' -TargetObjectName 'Fizz'
    
    Creates a synonym called `Buzz` to the object `Fizz`.
    
    .EXAMPLE
    Add-Synonym -SchemaName 'fiz' -Name 'Buzz' -TargetSchemaName 'baz' -TargetObjectName 'Buzz'
    
    Demonstrates how to create a synonym in a different schema.  Creates a synonym to the `baz.Buzz` object so that it can referenced as `fiz.Buzz`.
    
    .EXAMPLE
    Add-Synonym -Name 'Buzz' -TargetDatabaseName 'Fizzy' -TargetObjectName 'Buzz'
    
    Demonstrates how to create a synonym to an object in a different database.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The name of the synonym.
        $Name,
        
        [Parameter()]
        [string]
        # The name of the schema where the synonym should be created.
        $SchemaName = 'dbo',
        
        [Parameter()]
        [string]
        # The database where the target object is located.  Defaults to the current database.
        $TargetDatabaseName,
        
        [Parameter()]
        [string]
        # The scheme of the target object.  Defaults to `dbo`.
        $TargetSchemaName = 'dbo',
        
        [Parameter(Mandatory=$true,Position=2)]
        [string]
        # The target object's name the synonym will refer to.
        $TargetObjectName
    )

    $op = New-Object 'Rivet.Operations.AddSynonymOperation' $SchemaName, $Name, $TargetSchemaName, $TargetDatabaseName, $TargetObjectName
    Write-Host(' +[{0}].[{1}]' -f $SchemaName,$Name)
    Invoke-MigrationOperation -operation $op
}
