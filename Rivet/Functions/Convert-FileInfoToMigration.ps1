
function Convert-FileInfoToMigration
{
    <#
    .SYNOPSIS
    Converts a `System.IO.FileInfo` object containing a migration into a `Rivet.Operations.Operation` object.
    #>
    [CmdletBinding()]
    [OutputType([Rivet.Migration])]
    param(
        # The Rivet configuration to use.
        [Parameter(Mandatory)]
        [Rivet_Session] $Session,

        # The database whose migrations to get.
        [Parameter(Mandatory, ValueFromPipeline)]
        [IO.FileInfo] $InputObject
    )

    begin
    {
        Set-StrictMode -Version 'Latest'
        Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

        Write-Timing -Message 'Convert-FileInfoToMigration  BEGIN' -Indent

        function Add-Operation
        {
            param(
                [Parameter(Mandatory)]
                [Rivet.Migration] $Migration,

                # The migration object to invoke.
                [Parameter(Mandatory, ValueFromPipeline)]
                [Object] $Operation,

                [Parameter(ParameterSetName='Push', Mandatory)]
                [AllowEmptyCollection()]
                [Collections.Generic.List[Rivet.Operations.Operation]] $OperationsList,

                [Parameter(ParameterSetName='Pop', Mandatory)]
                [switch] $Pop
            )

            process
            {
                foreach( $operationItem in $Operation )
                {
                    if( $operationItem -isnot [Rivet.Operations.Operation] )
                    {
                        continue
                    }

                    # Set CommandTimeout on operation to value from Rivet configuration.
                    $operationItem.CommandTimeout = $Session.CommandTimeout

                    $pluginParameter = @{ Migration = $Migration ; Operation = $_ }

                    [Rivet.Operations.Operation[]]$operations = & {
                            Invoke-RivetPlugin -Session $Session `
                                               -Event ([Rivet.Events]::BeforeOperationLoad) `
                                               -Parameter $pluginParameter
                            $operationItem
                            Invoke-RivetPlugin -Session $Session `
                                               -Event ([Rivet.Events]::AfterOperationLoad) `
                                               -Parameter $pluginParameter
                        } |
                        Where-Object { $_ -is [Rivet.Operations.Operation] } |
                        Repair-Operation

                    $OperationsList.AddRange($operations)
                }
            }
        }

        function Clear-MigrationFunction
        {
            ('function:Push-Migration','function:Pop-Migration') |
                Where-Object { Test-Path -Path $_ } |
                Remove-Item -WhatIf:$false -Confirm:$false
        }

        Clear-MigrationFunction

        Import-RivetPlugin -Path $Session.PluginPaths -ModuleName $Session.PluginModules
    }

    process
    {
        foreach( $fileInfo in $InputObject )
        {
            $dbName = $fileInfo.DatabaseName

            Connect-Database -Session $Session -Name $dbName

            $m = [Rivet.Migration]::New($fileInfo.MigrationID, $fileInfo.MigrationName, $fileInfo.FullName, $dbName)
            $m | Add-Member -Name 'IsRivetMigration' -MemberType NoteProperty -Value $fileInfo.IsRivetMigration

            Write-Timing -Message ('Convert-FileInfoToMigration  {0}' -f $m.FullName)

            # Do not remove. It's a variable expected in some migrations.
            $DBMigrationsRoot = Split-Path -Parent -Path $fileInfo.FullName

            . $fileInfo.FullName | Out-Null

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

                Push-Migration | Add-Operation -Migration $m -OperationsList $m.PushOperations
                if( $m.PushOperations.Count -eq 0 )
                {
                    return
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

                Pop-Migration | Add-Operation -Migration $m -OperationsList $m.PopOperations
                if( $m.PopOperations.Count -eq 0 )
                {
                    return
                }

                $afterMigrationLoadParameter = @{ Migration = $m }
                & {
                    Invoke-RivetPlugin -Session $Session `
                                       -Event ([Rivet.Events]::AfterMigrationLoad) `
                                       -Parameter $afterMigrationLoadParameter
                }
                $m | Write-Output
            }
            finally
            {
                Clear-MigrationFunction
            }
        }
    }

    end
    {
        Write-Timing -Message 'Convert-FileInfoToMigration  END' -Outdent
    }
}