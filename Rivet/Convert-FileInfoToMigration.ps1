
function Convert-FileInfoToMigration
{
    <#
    .SYNOPSIS
    Converts a `System.IO.FileInfo` object containing a migration into a `Rivet.Operation` object.
    #>
    [CmdletBinding()]
    [OutputType([Rivet.Migration])]
    param(
        [Parameter(Mandatory=$true)]
        [Rivet.Configuration.Configuration]
        # The Rivet configuration to use.
        $Configuration,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [IO.FileInfo]
        # The database whose migrations to get.np
        $InputObject
    )

    begin
    {
        Set-StrictMode -Version 'Latest'

        function Clear-Migration
        {
            ('function:Push-Migration','function:Pop-Migration') |
                Where-Object { Test-Path -Path $_ } |
                Remove-Item -WhatIf:$false -Confirm:$false
        }

        Clear-Migration
        if( $Configuration.PluginsRoot )
        {
            Import-Plugin -Path $Configuration.PluginsRoot
        }
    }

    process
    {
        $InputObject | 
            ForEach-Object {
                $dbName = Split-Path -Parent -Path $_.FullName
                $dbName = Split-Path -Parent -Path $dbName
                $dbName = Split-Path -Leaf -Path $dbName

                $m = New-Object 'Rivet.Migration' $_.MigrationID,$_.MigrationName,$_.FullName,$dbName

                filter Add-Operation
                {
                    param(
                        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
                        [object]
                        # The migration object to invoke.
                        $Operation,

                        [Parameter(ParameterSetName='Push',Mandatory=$true)]
                        [Collections.Generic.List[Rivet.Operation]]
                        [AllowEmptyCollection()]
                        $OperationsList,

                        [Parameter(ParameterSetName='Pop',Mandatory=$true)]
                        [Switch]
                        $Pop
                    )

                    Set-StrictMode -Version 'Latest'

                    $Operation |
                        Where-Object { $_ -is [Rivet.Operation] } |
                        ForEach-Object {
                            if( (Test-Path -Path 'function:Start-MigrationOperation') )
                            {
                                Start-MigrationOperation -Migration $m -Operation $_
                            }

                            $_

                            if( (Test-Path -Path 'function:Complete-MigrationOperation') )
                            {
                                Complete-MigrationOperation -Migration $m -Operation $_
                            }
                        } |
                        Where-Object { $_ -is [Rivet.Operation] } |
                        ForEach-Object { $OperationsList.Add( $_ ) } |
                        Out-Null
                }

                $DBMigrationsRoot = Split-Path -Parent -Path $_.FullName

                . $_.FullName

                try
                {
                    if( -not (Test-Path -Path 'function:Push-Migration') )
                    {
                        throw (@'
Push-Migration function not found. All migrations are required to have a Push-Migration function that contains at least one operation. Here's some sample code to get you started:

    function Push-Migration
    {
        Add-Table 'LetsCreateATable' {
            int 'ID' -NotNull
        }
    }
'@)
                    }

                    Push-Migration | Add-Operation -OperationsList $m.PushOperations
                    if( $m.PushOperations.Count -eq 0 )
                    {
                        throw (@'
Push-Migration function is empty and contains no operations. Maybe you''d like to create a table? Here's some sample code to get you started:

    function Push-Migration
    {
        Add-Table 'LetsCreateATable' {
            int 'ID' -NotNull
        }
    }
'@)
                    }
                
                    if( -not (Test-Path -Path 'function:Pop-Migration') )
                    {
                        throw (@'
Pop-Migration function not found. All migrations are required to have a Pop-Migration function that contains at least one operation. Here's some sample code to get you started:

    function Pop-Migration
    {
        Remove-Table 'LetsCreateATable'
    }
'@)
                        return
                    }

                    Pop-Migration | Add-Operation  -OperationsList $m.PopOperations
                    if( $m.PopOperations.Count -eq 0 )
                    {
                        throw (@'
Pop-Migration function is empty and contains no operations. Maybe you''d like to drop a table? Here's some sample code to get you started:

    function Pop-Migration
    {
        Remove-Table 'LetsCreateATable'
    }
'@)
                    }

                    $m
                }
                catch
                {
                    Write-RivetError -Message ('Loading migration ''{0}'' failed' -f $m.Path) `
                                     -CategoryInfo $_.CategoryInfo.Category `
                                     -ErrorID $_.FullyQualifiedErrorID `
                                     -Exception $_.Exception `
                                     -CallStack ($_.ScriptStackTrace) 
                }
                finally
                {
                    Clear-Migration
                }
            } | 
            Where-Object { $_ -is [Rivet.Migration] }
    }

    end
    {
    }
}