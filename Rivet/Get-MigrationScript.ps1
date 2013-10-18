
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
        $Path
    )

    process
    {
        $Path | ForEach-Object {
            if( (Test-Path $_ -PathType Container) )
            {
                Get-ChildItem $_ '*_*.ps1'
            }
            elseif( (Test-Path $_ -PathType Leaf) )
            {
                Get-Item $_
            }
            else
            {
                #Write-Error ('Migration path ''{0}'' not found.' -f $_)
            }
        
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
        }
    }
}