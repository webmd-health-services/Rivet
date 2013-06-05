
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
        [string[]]
        # The databases where the migration script(s) will be run/applied.
        $Database,
        
        [Parameter(Mandatory=$true)]
        [string]
        # The root where scripts for all databases are kept.  Migrations will be created in Migrations directory, under a parent directory for each database, e.g. `$Path\$Database\Migrations`.
        $Path
    )

    if( -not (Test-Path -Path $Path -PathType Container) )
    {
        Write-Host ('Creating databases directory {0}.' -f $Path)
        $null = New-Item -Path $Path -ItemType Directory
    }
    
    $singleDatabase = ($Database.Length -eq 1)
    
    $Database | ForEach-Object {
    
        if( $singleDatabase )
        {
            $dbRootPath = $Path
        }
        else
        {
            $dbRootPath = Join-Path $Path $_
        }
        
        if( -not (Test-Path -Path $dbRootPath -PathType Container) )
        {
            Write-Host ('Creating {0} database directory {1}.' -f $_,$dbRootPath)
            $null = New-Item -Path $dbRootPath -ItemType Directory
        }
        
        $dbMigrationPath = Join-Path $dbRootPath 'Migrations'
        if( -not (Test-Path -Path $dbMigrationPath -PathType Container) )
        {
            Write-Host ('Creating {0} database migrations directory {1}.' -f $_,$dbMigrationPath)
            $null = New-Item -Path $dbMigrationPath -ItemType Directory
        }
        
        $id = (Get-Date).ToString('yyyyMMddHHmmss')
        $filename = '{0}_{1}.ps1' -f $id,$Name

        $migrationPath = Join-Path $dbMigrationPath $filename
        New-Item -Path $migrationPath -Force -ItemType File

        @"
<#
Your migration is ready to go!  We've set you up with default migrations that just run raw SQL.  Here are some other migrations:

If you have a script for a scripted object, you can use these functions:

    Add-Column [-Name] <String> <-BigInt|-Int|-SmallInt|-TinyInt|-Date|-Time|-Money|-SmallMoney|-Bit|-SqlVariant|-RowVersion|-HierarchyID> [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-TableSchema <String>]
    Add-Column [-Name] <String> <-VarChar|-Char> [[-Size] <Int64>] [-Unicode] [-Collation <String>] [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-TableSchema <String>]
    Add-Column [-Name] <String> <-Binary|-VarBinary> [-Size] <Int64> [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-TableSchema <String>]
    Add-Column [-Name] <String> <-BigInt|-Int|-SmallInt|-TinyInt> -Identity [[-Seed] <Int32>] [[-Increment] <Int32>] [-NotForReplication] [-Description <String>] -TableName <String> [-TableSchema <String>] 
    Add-Column [-Name] <String> <-Numeric|-Decimal> [-Precision] <Int32> -Identity [[-Seed] <Int32>] [[-Increment] <Int32>] [-NotForReplication] [-Description <String>] -TableName <String>  [-TableSchema <String>]
    Add-Column [-Name] <String> <-Numeric|-Decimal> [-Precision] <Int32> [[-Scale] <Int32>] [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-TableSchema <String>]
    Add-Column [-Name] <String> -Float [[-Precision] <Int32>] [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-TableSchema <String>] 
    Add-Column [-Name] <String> -Datetime2 [[-Precision] <Int32>] [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-TableSchema <String>] 
    Add-Column [-Name] <String> -DateTimeOffset [[-Precision] <Int32>] [[-Scale] <Int32>] [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-TableSchema <String>]
    Add-Column [-Name] <String> -UniqueIdentifier [-RowGuidCol] [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-TableSchema <String>] 
    Add-Column [-Name] <String> -Xml [-Document] [-XmlSchemaCollection <String>] [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-TableSchema <String>]
    Add-Column [-Name] <String> [-DataType] <String> [-Sparse] [-NotNull] [-Default <Object>] [-Description <String>] -TableName <String> [-TableSchema <String>] 
    Remove-StoredProcedure -Name <string> [-Schema <string>] [-IfExists]
    Remove-UserDefinedFunction -Name <string> [-Schema <string>] [-IfExists]
    Remove-View -Name <string> [-Schema <string>] [-IfExists]
    Set-StoredProcedure -Name <string> [-Schema <string>]
    Set-UserDefinedFunction -Name <string> [-Schema <string>]
    Set-View -Name <string> [-Schema <string>]
    
To execute raw SQL:

    Invoke-Query -Query <string>

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
"@ | Out-File -FilePath $migrationPath -Encoding OEM

    }
    
}