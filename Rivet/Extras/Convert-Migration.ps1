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
    $ConfigFilePath
)

Set-StrictMode -Version 'Latest'

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
if( $PSBoundParameters.ContainsKey( 'ConfigFilePath' ) )
{
    $getMigrationParams.ConfigFilePath = $ConfigFilePath
}
Get-Migration @getMigrationParams |
    ForEach-Object { 
        $migration = $_

        $header = @'
-- {0}_{1}
'@ -f $migration.ID,$migration.Name

        $schemaScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.Schema.sql' -f $migration.Database)
        $codeObjectScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.CodeObject.sql' -f $migration.Database)
        $dataScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.Data.sql' -f $migration.Database)
        $unknownScriptPath = Join-Path -Path $OutputPath -ChildPath ('{0}.Unknown.sql' -f $migration.Database)

        # Aggregate changes
        $addTableOps = @{ }

        $operations = $migration.PushOperations | ForEach-Object {
            $op = $_
            $opType = $op.GetType().Name
            if( $opType -eq 'AddTableOperation' )
            {
                $key = '{0}.{1}' -f $op.SchemaName,$op.Name
                $addTableOps[$key] = $op
                return $_
            }

            if( $opType -eq 'UpdateTableOperation' )
            {
                $key = '{0}.{1}' -f $op.SchemaName,$op.Name
                if( -not ($addTableOps.ContainsKey( $key )) )
                {
                    return $_
                }

                $addTableOp = $addTableOps[$key]
                Invoke-Command {
                            $op.AddColumns
                            $op.UpdateColumns
                        } | 
                    ForEach-Object {
                        $column = $_
                        $columnIdx = $null
                        for( $idx = 0; $idx -lt $addTableOp.Columns.Count; ++$idx )
                        {
                            if( $addTableOp.Columns[$idx].Name -eq $column.Name )
                            {
                                $columnIdx = $idx
                            }
                        }
                        if( $columnIdx -eq $null )
                        {
                            $addTableOp.Columns.Add( $column )
                        }
                        else
                        {
                            $null = $addTableOp.Columns.RemoveAt( $columnIdx )
                            $addTableOp.Columns.Insert( $columnIdx, $column )
                        }
                    }

                return
            }

            return $_
        }

        $operations | ForEach-Object {

            $op = $_
            $path = switch -Regex ( $op.GetType() )
            {
                '(Add|Remove|Update)(CheckConstraint|DataType|DefaultConstraint|ExtendedProperty|ForeignKey|Index|PrimaryKey|Schema|Table|Trigger|UniqueKey|Column)'
                {
                    if( $Matches[2] -eq 'ExtendedProperty' -and $op.ForView )
                    {
                        $codeObjectScriptPath
                    }
                    else
                    {
                        $schemaScriptPath
                    }
                    break
                }

                'Rename(Column|Constraint|Index)?Operation'
                {
                    $schemaScriptPath
                }

                '(Add|Remove|Update)(StoredProcedure|Synonym|UserDefinedFunction|View)'
                {
                    $codeObjectScriptPath
                    break
                }

                '(Add|Remove|Update)Row'
                {
                    $dataScriptPath
                    break
                }

                'RawQuery'
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
