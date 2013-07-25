
function New-Migration
{
    <#
    .SYNOPSIS
    Creates a new migration script.
    
    .DESCRIPTION
    Creates a migration script with a given name.  The script is prefixed with the current timestamp (e.g. yyyyMMddHHmmss).  The script is created in `$Path\$Database\Migrations`.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the migration to create.
        $Name,
        
        [Parameter(Mandatory=$true)]
        [string]
        # The path to the directory where the migration should be saved.
        $Path
    )

    $id = (Get-Date).ToString('yyyyMMddHHmmss')
    $filename = '{0}_{1}.ps1' -f $id,$Name

    $migrationPath = Join-Path $Path $filename
    New-Item -Path $migrationPath -Force -ItemType File

        @"
<#
Your migration is ready to go!  Here are all the built-in migrations you can use:

    Add-Column [-Name] <String> <-BigInt|-Int|-SmallInt|-TinyInt|-Date|-Time|-Money|-SmallMoney|-Bit|-SqlVariant|-RowVersion|-HierarchyID> [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-SchemaName <String>]
    Add-Column [-Name] <String> <-VarChar|-Char> [[-Size] <Int64>] [-Unicode] [-Collation <String>] [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-SchemaName <String>]
    Add-Column [-Name] <String> <-Binary|-VarBinary> [-Size] <Int64> [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-SchemaName <String>]
    Add-Column [-Name] <String> <-BigInt|-Int|-SmallInt|-TinyInt> -Identity [[-Seed] <Int32>] [[-Increment] <Int32>] [-NotForReplication] [-Description <String>] -TableName <String> [-SchemaName <String>] 
    Add-Column [-Name] <String> <-Numeric|-Decimal> [-Precision] <Int32> -Identity [[-Seed] <Int32>] [[-Increment] <Int32>] [-NotForReplication] [-Description <String>] -TableName <String>  [-SchemaName <String>]
    Add-Column [-Name] <String> <-Numeric|-Decimal> [-Precision] <Int32> [[-Scale] <Int32>] [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-SchemaName <String>]
    Add-Column [-Name] <String> -Float [[-Precision] <Int32>] [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-SchemaName <String>] 
    Add-Column [-Name] <String> -Datetime2 [[-Precision] <Int32>] [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-SchemaName <String>] 
    Add-Column [-Name] <String> -DateTimeOffset [[-Precision] <Int32>] [[-Scale] <Int32>] [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-SchemaName <String>]
    Add-Column [-Name] <String> -UniqueIdentifier [-RowGuidCol] [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-SchemaName <String>] 
    Add-Column [-Name] <String> -Xml [-Document] [-XmlSchemaCollection <String>] [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-SchemaName <String>]
    Add-Column [-Name] <String> [-DataType] <String> [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-SchemaName <String>] 
    Add-Description [-Description] <String> [-SchemaName <String>] -TableName <String> [-ColumnName <String>]
    Add-Table [-Name] <String> [-Column] { 
            New-Column <Same Parameters as Add-Column> 
            [ ; New-Column <Same Parameters as Add-Column> ... ] 
        } [-SchemaName <string>] [-FileGroup <String>] [-TextImageFileGroup <String>] [-FileStreamFileGroup <String>] [-Option <String[]>]
    Add-Table [-Name] <String> -FileTable  [-SchemaName <string>] [-FileGroup <String>] [-TextImageFileGroup <String>] [-FileStreamFileGroup <String>] [-Option <String[]>]
    Remove-Column -Name <string> -TableName <string> [-SchemaName <string>]
    Remove-Description [-SchemaName <String>] -TableName <String> [-ColumnName <String>]
    Remove-StoredProcedure -Name <string> [-Schema <string>] [-IfExists]
    Remove-UserDefinedFunction -Name <string> [-Schema <string>] [-IfExists]
    Remove-View -Name <string> [-Schema <string>] [-IfExists]
    Set-StoredProcedure -Name <string> [-Schema <string>]
    Set-UserDefinedFunction -Name <string> [-Schema <string>]
    Set-View -Name <string> [-Schema <string>]
    Update-Description [-Description] <String> [-SchemaName <String>] -TableName <String> [-ColumnName <String>]
    
To execute raw SQL:

    Invoke-Query [-Query] <String>

You can use a PowerShell here string for longer queries and so you don't have to escape quotes:

    Invoke-Query -Query @'
       -- SQL goes here    
'@  # '@ must be the first two characters on the line to close the string.
 
To execute a raw SQL script *file*:

    Invoke-SqlScript -Path <string>

To get the path to a script, use the `$DBScriptRoot` variable, which is set to the current databases scripts root directory:

    $scriptPath = Join-Path $DBScriptRoot Miscellaneous\CreateMyCustomObject.sql
    Invoke-SqlScript -Path $scriptPath
    
#>

function Push-Migration()
{
}

function Pop-Migration()
{
}
"@ | Set-Content -Path $migrationPath

}