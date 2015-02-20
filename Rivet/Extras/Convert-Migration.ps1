<#
.SYNOPSIS
Demonstrates how to use the Rivet object model to convert migrations to standalone SQL scripts.

.DESCRIPTION
Sometimes you can't run your migration scripts directly against a database.  In these situations, it is useful to be able to grab the SQL from your migrations and convert them into a different form.  This script demonstates how to do that by outputing your migrations into four different files per database: one for schema changes, one for code object changes, one for data, and one for unknown kinds of changes.

.EXAMPLE
Convert-Migration.ps1 -OutputPath 'F:\BuildOutput\DBScripts'

Demonstrates how to run `Convert-Migration.ps1`.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]
    # The directory where the scripts should be output.
    $OutputPath,

    [Parameter()]
    [string]
    # The path to the rivet.json file to use.  By default, it will look in the current directory.
    $ConfigFilePath,

    [Parameter()]
    [Hashtable]
    # Mapping of migration base name (e.g. `20130115142433_CreateTable`) to the person's name who created it.
    $Author = @{ },

    [string[]]
    # A list of migrations to include. Only migrations that match are returned.  Wildcards permitted.
    $Include,

    [string[]]
    # Any migrations/files to exclude.  Wildcards accepted.
    $Exclude,

    [DateTime]
    # Only get migrations before this date/time.
    $Before,

    [DateTime]
    # Only get migrations after this date/time.
    $After
)

Set-StrictMode -Version 'Latest'

function Get-ColumnIndex
{
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        # The column to check for.
        $Name,

        [Parameter(Mandatory=$true)]
        [Collections.Generic.List[Rivet.Column]]
        [AllowEmptyCollection()]
        # The column collection to modify
        $List
    )

    $columnIdx = $null
    for( $idx = 0; $idx -lt $List.Count; ++$idx )
    {
        if( $List[$idx].Name -eq $Name )
        {
            return $idx
        }
    }
}

filter Add-Column
{
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [Rivet.Column]
        # The column to check for.
        $Column,

        [Parameter(Mandatory=$true)]
        [Collections.Generic.List[Rivet.Column]]
        [AllowEmptyCollection()]
        # The column collection to modify
        $List,

        [Switch]
        # Replace only, don't add.
        $ReplaceOnly,

        [Switch]
        # Return columns that aren't found.
        $PassThru
    )

    $columnIdx = Get-ColumnIndex -Name $Column.Name -List $List
    if( $columnIdx -eq $null )
    {
        if( $ReplaceOnly )
        {
            if( $PassThru )
            {
                return $Column
            }
        }
        else
        {
            [void] $List.Add( $column )
        }
    }
    else
    {
        $null = $List.RemoveAt( $columnIdx )
        $List.Insert( $columnIdx, $column )
    }
}

filter Remove-Column
{
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        # The column to check for.
        $Name,

        [Parameter(Mandatory=$true)]
        [Collections.Generic.List[Rivet.Column]]
        [AllowEmptyCollection()]
        # The column collection to modify
        $List,

        [Switch]
        # Return the column name if it *wasn't* removed.
        $PassThru
    )

    $columnIdx = Get-ColumnIndex -Name $Name -List $List
    if( $columnIdx -ne $null )
    {
        [void] $List.RemoveAt( $columnIdx )
    }
    else
    {
        if( $PassThru )
        {
            return $Name
        }
    }
}

& (Join-Path -Path $PSScriptRoot -ChildPath '..\Import-Rivet.ps1' -Resolve)

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

$operations = New-Object 'Collections.ArrayList'
$newTables = New-Object 'Collections.Generic.HashSet[string]'
$opIdx = @{ }

Get-Migration @getMigrationParams |
    ForEach-Object { 
        $migration = $_
        $migration
        $migrationName = '{0}_{1}' -f $migration.ID,$migration.Name
        $authorMsg = ''
        if( $Author.ContainsKey( $migrationName ) )
        {
            $authorMsg = ' by {0}' -f $Author[$migrationName]
        }
        Write-Verbose ('{0}{1}' -f $migrationName,$authorMsg)

        $migration.PushOperations |
            Add-Member -MemberType NoteProperty -Name 'Migrations' -Value @() -PassThru |
            Add-Member -MemberType NoteProperty -Name 'Database' -Value $migration.Database -PassThru |
            ForEach-Object {
                $op = $_
                $op.Migrations += $migrationName

                if( $op -is [Rivet.Operations.AddTableOperation] )
                {
                    [void] $newTables.Add( $op.ObjectName )
                }

                if( $op -is [Rivet.Operations.RenameColumnOperation] )
                {
                    $tableName = '{0}.{1}' -f $op.SchemaName,$op.TableName
                    if( $opIdx.ContainsKey( $tableName ) )
                    {
                        $tableOp = $operations[$opIdx[$tableName]]
                        if( $tableOp -is [Rivet.Operations.AddTableOperation] )
                        {
                            $originalColumn = $tableOp.Columns | Where-Object { $_.Name -eq $op.Name }
                            if( $originalColumn )
                            {
                                $originalColumn.Name = $op.NewName
                                return
                            }
                        }
                    }
                }

                if( $op -is [Rivet.Operations.RenameOperation] )
                {
                    $objectName = '{0}.{1}' -f $op.SchemaName,$op.Name
                    if( $opIdx.ContainsKey( $objectName ) )
                    {
                        $existingOp = $operations[$opIdx[$objectName]]
                        if( $existingOp -is [Rivet.Operations.AddTableOperation] )
                        {
                            $existingOp.Name = $op.NewName
                            return
                        }
                    }
                }

                if( $op -isnot [Rivet.Operations.ObjectOperation] )
                {
                    $null = $operations.Add( $op )
                    return
                }

                if( $opIdx.ContainsKey( $op.ObjectName ) )
                {
                    $idx = $opIdx[$op.ObjectName]
                    $existingOp = $operations[$idx]

                    $opTypeName = $op.GetType().Name
                    if( $opTypeName -like 'Remove*' )
                    {
                        $operations[$idx] = $null
                        return
                    }
                    elseif( $opTypeName -eq 'UpdateTableOperation' )
                    {
                        if( $existingOp.Migrations -notcontains $migrationName )
                        {
                            $existingOp.Migrations += $migrationName
                        }

                        if( $existingOp -is [Rivet.Operations.AddTableOperation] )
                        {
                            $op.AddColumns | Add-Column -List $existingOp.Columns
                            $op.UpdateColumns | Add-Column -List $existingOp.Columns
                            $op.RemoveColumns | Remove-Column -List $existingOp.Columns
                        }
                        elseif( $existingOp -is [Rivet.Operations.UpdateTableOperation] )
                        {
                            # Add new columns to the original operation
                            $op.AddColumns | Add-Column -List $existingOp.AddColumns

                            # Replace existing column definitions
                            $op.UpdateColumns | 
                                Add-Column -List $existingOp.AddColumns -ReplaceOnly -PassThru |
                                Add-Column -List $existingOp.UpdateColumns

                            # Remove collumsn
                            $op.RemoveColumns | 
                                Remove-Column -List $existingOp.AddColumns -PassThru |
                                Remove-Column -List $existingOp.UpdateColumns -PassThru |
                                ForEach-Object { [void] $existingOp.RemoveColumns.Add( $_ )  }
                        }
                        else
                        {
                            Write-Error ('Unhandled operation of type ''{0}''.' -f $existingOp.GetType())
                        }                        
                        return
                    }
                }

                $null = $operations.Add( $op )
                $opIdx[$op.ObjectName] = $operations.Count - 1
            } 
    }
    

    # Now, output the cumulative changes.
    $operations | Where-Object { $_ } | ForEach-Object {

        $op = $_

        $schemaScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.Schema.sql' -f $op.Database)
        $dependentObjectScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.DependentObject.sql' -f $op.Database)
        $extendedPropertyScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.ExtendedProperty.sql' -f $op.Database)
        $codeObjectScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.CodeObject.sql' -f $op.Database)
        $dataScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.Data.sql' -f $op.Database)
        $unknownScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.Unknown.sql' -f $op.Database)

        $header = $op.Migrations | ForEach-Object {
            $name = $_
            $by = ''
            if( $Author -and $Author.ContainsKey( $name ) )
            {
                $by = ': {0}' -f $Author[$name]
            }
            '-- {0}{1}' -f $name,$by
        } 
        $header = $header -join ([Environment]::NewLine)
        
        $op = $_
        $path = switch -Regex ( $op.GetType() )
        {
            '(Add|Remove|Update)ExtendedProperty'
            {
                $extendedPropertyScriptPath
                break
            }

            '(Add|Remove|Update)(DataType|Schema|Table|Trigger)'
            {
                $schemaScriptPath
                break
            }

            '(Add|Remove|Update)(CheckConstraint|DefaultConstraint|ForeignKey|Index|PrimaryKey|UniqueKey)'
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

            'Rename(Column|Constraint|Index)?Operation'
            {
                $schemaScriptPath
            }

            '(Add|Remove|Update)(CodeObjectMetadata|StoredProcedure|Synonym|UserDefinedFunction|View)'
            {
                $codeObjectScriptPath
                break
            }

            '(Add|Remove|Update)Row'
            {
                $dataScriptPath
                break
            }

            'RawQuery|ScriptFile'
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
