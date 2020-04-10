
function Get-MigrationFile
{
    <#
    .SYNOPSIS
    Gets the migration script files.
    #>
    [CmdletBinding(DefaultParameterSetName='External')]
    [OutputType([IO.FileInfo])]
    param(
        [Parameter(Mandatory=$true)]
        [Rivet.Configuration.Configuration]
        # The configuration to use.
        $Configuration,

        [Parameter(Mandatory=$true,ParameterSetName='ByPath')]
        [string[]]
        # The path to a migrations directory to get.
        $Path,

        [string[]]
        # A list of migrations to include. Matches against the migration's ID or Name or the migration's file name (without extension). Wildcards permitted.
        $Include,

        [string[]]
        # A list of migrations to exclude. Matches against the migration's ID or Name or the migration's file name (without extension). Wildcards permitted.
        $Exclude
    )

    Set-StrictMode -Version Latest
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    
    Write-Timing -Message 'Get-MigrationFile  BEGIN' -Indent

    $requiredMatches = @{ }
    if( $PSBoundParameters.ContainsKey('Include') )
    {
        foreach( $includeItem in $Include )
        {
            if( -not [Management.Automation.WildcardPattern]::ContainsWildcardCharacters($includeItem) )
            {
                $requiredMatches[$includeItem] = $true
            }
        }
    }

    $foundMatches = @{ }
    
    Invoke-Command -ScriptBlock {
            if( $PSCmdlet.ParameterSetName -eq 'ByPath' )
            {
                $Path
            }
            else
            {
                $Configuration.Databases | Select-Object -ExpandProperty 'MigrationsRoot'
            }
        } |
        ForEach-Object {
            Write-Debug -Message $_ 
            if( (Test-Path -Path $_ -PathType Container) )
            {
                Get-ChildItem -Path $_ -Filter '*_*.ps1'
            }
            elseif( (Test-Path -Path $_ -PathType Leaf) )
            {
                Get-Item -Path $_
            }
        } | 
        ForEach-Object {
            if( $_.BaseName -notmatch '^(\d{14})_(.+)' )
            {
                Write-Error ('Migration {0} has invalid name.  Must be of the form `YYYYmmddhhMMss_MigrationName.ps1' -f $_.FullName)
                return
            }
        
            $id = [int64]$matches[1]
            $name = $matches[2]
        
            $_ | 
                Add-Member -MemberType NoteProperty -Name 'MigrationID' -Value $id -PassThru |
                Add-Member -MemberType NoteProperty -Name 'MigrationName' -Value $name -PassThru
        } |
        Where-Object {
            if( -not ($PSBoundParameters.ContainsKey( 'Include' )) )
            {
                return $true
            }

            $migration = $_
            foreach( $includeItem in $Include )
            {
                $foundMatch = $migration.MigrationID -like $includeItem -or $migration.MigrationName -like $includeItem -or $migration.BaseName -like $includeItem
                if( $foundMatch )
                {
                    $foundMatches[$includeItem] = $true
                    return $true
                } 
            }

            return $false
        } |
        Where-Object { 

            if( -not ($PSBoundParameters.ContainsKey( 'Exclude' )) )
            {
                return $true
            }

            $migration = $_
            $Exclude | Where-Object { $migration.MigrationID -notlike $_ -and $migration.MigrationName -notlike $_ -and $migration.BaseName -notlike $_ }
        } 

    foreach( $requiredMatch in $requiredMatches.Keys )
    {
        if( -not $foundMatches.ContainsKey( $requiredMatch ) )
        {
            Write-Error ('Migration ''{0}'' not found.' -f $requiredMatch)
        }
    }

    Write-Timing -Message 'Get-MigrationFile  BEGIN' -Outdent
}
