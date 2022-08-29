
function Complete-Migration
{
    [CmdletBinding()]
    [Rivet.Plugin([Rivet.Events]::AfterMigrationLoad)]
    param(
        # The migration the operation is part of
        [Parameter(Mandatory)]
        [Rivet.Migration] $Migration
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    
    $problems = $false 

    # Validations happens here 
    # If validation fails then set $problems = $true

    if( $problems )
    {
        throw "There were errors running ""$($Migration.Name)"". Please see previous errors for details."
    }
}
