
function Get-MigrationScript
{
    <#
    .SYNOPSIS
    Gets the migration scripts at or in a path.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string[]]
        # The path to the migration.
        $Path,

        [string[]]
        # A list of migrations to exclude.  Wildcards accepted.
        $Exclude,

        [DateTime]
        # Only get migrations before this date.  Default is all.
        $Before,

        [DateTime]
        # Only get migrations after this date.  Default is all.
        $After
    )

    process
    {
        $excludeParam = @{ }

        $Path | ForEach-Object {
            if( (Test-Path -Path $_ -PathType Container) )
            {
                Get-ChildItem -Path $_ -Filter '*_*.ps1'
            }
            elseif( (Test-Path -Path $_ -PathType Leaf) )
            {
                Get-Item -Path
            }
            else
            {
                #Write-Error ('Migration path ''{0}'' not found.' -f $_)
            }
        
        } | 
        Where-Object { 
            $script = $_
            if( $PSBoundParameters.ContainsKey( 'Exclude' ) )
            {
                $foundMatch = $Exclude | Where-Object { $script.BaseName -like $_ }
                return -not $foundMatch
            }

            return $true
        } |
        ForEach-Object {
            if( $_.BaseName -notmatch '^(\d{14})_(.+)' )
            {
                Write-Error ('Migration {0} has invalid name.  Must be of the form `YYYYmmddhhMMss_MigrationName.ps1' -f $_.FullName)
                return
            }
        
            $id = [UInt64]$matches[1]
            $name = $matches[2]
        
            $_ | 
                Add-Member -MemberType NoteProperty -Name 'MigrationID' -Value $id -PassThru |
                Add-Member -MemberType NoteProperty -Name 'MigrationName' -Value $name -PassThru
        } |
        Where-Object {
            if( $PSBoundParameters.ContainsKey( 'Before' ) )
            {
                $beforeTimestamp = [uint64]$Before.ToString('yyyyMMddHHmmss')
                if( $_.MigrationID -gt $beforeTimestamp )
                {
                    return $false
                }
            }

            if( $PSBoundParameters.ContainsKey( 'After' ) )
            {
                $afterTimestamp = [uint64]$After.ToString('yyyyMMddHHmmss')
                if( $_.MigrationID -lt $afterTimestamp )
                {
                    return $false
                }
            }
            return $true
        }
    }
}