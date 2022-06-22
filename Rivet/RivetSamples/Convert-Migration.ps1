<#
.SYNOPSIS
Demonstrates how to use the Rivet object model to convert migrations to standalone SQL scripts.

.DESCRIPTION
Sometimes you can't run your migration scripts directly against a database.  In these situations, it is useful to be able to grab the SQL from your migrations and convert them into a different form.  This script demonstates how to do that by outputing your migrations into four different files per database: one for schema changes, one for code object changes, one for data, and one for unknown kinds of changes.

.LINK
Merge-Migration

.EXAMPLE
Convert-Migration.ps1 -OutputPath 'F:\BuildOutput\DBScripts'

Demonstrates how to run `Convert-Migration.ps1`.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    # The directory where the scripts should be output.
    [String]$OutputPath,

    # The path to the rivet.json file to use.  By default, it will look in the current directory.
    [String]$ConfigFilePath,

    # Mapping of migration base name (e.g. `20130115142433_CreateTable`) to the person's name who created it.
    [hashtable]$Author = @{ },

    # A list of migrations to include. Only migrations that match are returned.  Wildcards permitted.
    [String[]]$Include,

    # Any migrations/files to exclude.  Wildcards accepted.
    [String[]]$Exclude,

    # Only get migrations before this date/time.
    [DateTime]$Before,

    # Only get migrations after this date/time.
    [DateTime]$After
)

$timer = New-Object 'Diagnostics.Stopwatch'
$timerForWrites = New-Object 'Diagnostics.Stopwatch'

function Write-Timing
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Message
    )
            
    if( -not $timer.IsRunning )
    {
        $timer.Start()
    }
    if( -not $timerForWrites.IsRunning )
    {
        $timerForWrites.Start()
    }
            
    Write-Debug -Message ('Convert-Migration  {0}  {1}  {2}' -f $timer.Elapsed,$timerForWrites.Elapsed,$Message)
    $timerForWrites.Restart()
}

#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

Write-Timing -Message ('BEGIN')

& (Join-Path -Path $PSScriptRoot -ChildPath '..\Import-Rivet.ps1' -Resolve)
Write-Timing -Message ('  Import-Rivet.ps1')

if( -not (Test-Path -Path $OutputPath -PathType Container) )
{
    $null = New-Item -ItemType 'Directory' -Path $OutputPath -Force
}
else
{
    Get-ChildItem -Path $OutputPath -File | Remove-Item
}

$getMigrationParams = @{ }
@( 'ConfigFilePath', 'Exclude', 'Include', 'Before', 'After' ) |
    Where-Object { $PSBoundParameters.ContainsKey( $_ ) } |
    ForEach-Object { $getMigrationParams.$_ = Get-Variable -Name $_ -ValueOnly }

$newTables = New-Object 'Collections.Generic.HashSet[string]'

$migrations = Get-Migration @getMigrationParams

$mergedMigrations = $migrations | Merge-Migration

foreach( $migration in $mergedMigrations )
{
    Write-Timing -Message ('    {0}' -f $migration.FullName)

    $name = $migration.Path | Split-Path -Leaf
    $name = [IO.Path]::GetFileNameWithoutExtension($name)
    $header = ''
    if( $Author -and $Author.ContainsKey($name) )
    {
        $header = ': {0}' -f $Author[$name]
    }
    $header = '-- {0}{1}' -f $name,$header

    foreach( $op in $migration.PushOperations )
    {
        if( -not $op )
        {
            continue
        }

        Write-Timing -Message ('      {0}' -f $op.GetType().FullName)

        $schemasScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.Schemas.sql' -f $migration.Database)
        $schemaScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.Schema.sql' -f $migration.Database)
        $dependentObjectScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.DependentObject.sql' -f $migration.Database)
        $extendedPropertyScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.ExtendedProperty.sql' -f $migration.Database)
        $codeObjectScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.CodeObject.sql' -f $migration.Database)
        $dataScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.Data.sql' -f $migration.Database)
        $unknownScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.Unknown.sql' -f $migration.Database)
        $triggerScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.Trigger.sql' -f $migration.Database)
        $constraintScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.Constraint.sql' -f $migration.Database)
        $foreignKeyScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.ForeignKey.sql' -f $migration.Database)
        $typeScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.Type.sql' -f $migration.Database)

        if( $op -is [Rivet.Operations.AddTableOperation] )
        {
            $newTables.Add( $op.ObjectName ) | Out-Null
        }
        
        $path = switch -Regex ( $op.GetType() )
        {
            '(Add|Remove|Update)ExtendedProperty'
            {
                $extendedPropertyScriptPath
                break
            }

            '(Add|Remove|Update)Schema'
            {
                $schemasScriptPath
                break
            }

            '(Add|Remove|Update)(Table|RowGuidCol)'
            {
                $schemaScriptPath
                break
            }

            '(Add|Remove|Update)Trigger'
            {
                $triggerScriptPath
                break
            }

            '(Add|Remove|Update)(Index|PrimaryKey|UniqueKey)'
            {
                $tableName = '{0}.{1}' -f $op.SchemaName,$op.TableName
                if( $newTables.Contains( $tableName ) )
                {
                    $schemaScriptPath
                }
                else
                {
                    $dependentObjectScriptPath
                }
                break
            }

            '(Add|Remove)(CheckConstraint|DefaultConstraint)'
            {
                $constraintScriptPath
                break
            }

            '(Enable|Disable)Constraint'
            {
                $constraintScriptPath
                break
            }

            '(Add|Remove|Disable|Enable)ForeignKey'
            {
                $foreignKeyScriptPath
                break
            }

            '(Add|Remove|Update)(DataType|Synonym)'
            {
                $typeScriptPath
                break
            }

            'Rename(Column|Constraint|DataType|Index|Object)?Operation'
            {
                $schemaScriptPath
            }

            '(Add|Remove|Update)(CodeObjectMetadata|StoredProcedure|UserDefinedFunction|View)'
            {
                $codeObjectScriptPath
                break
            }

            '(Add|Remove|Update)Row'
            {
                $dataScriptPath
                break
            }

            'RawDdl|ScriptFile'
            {
                Write-Warning ('Generic migration operation found in ''{0}''.' -f $migration.Path)
                $unknownScriptPath
                break
            }

            default
            {
                Write-Error ('Unknown migration operation ''{0}'' in ''{1}''.' -f $op.GetType(),$migration.Path)
                return
            }
        }

        if( -not (Test-Path -Path $path -PathType Leaf) )
        {
            $null = New-Item -Path $path -ItemType 'File' -Force
        }

        $header | Add-Content -Path $path
        $op.ToIdempotentQuery() | Add-Content -Path $path
        ("GO{0}" -f [Environment]::NewLine) | Add-Content -Path $path
    }
}

Write-Timing -Message ('END')
