
function Invoke-SqlScript
{
    <#
    .SYNOPSIS
    Runs a SQL script file as part of a migration.
    
    .DESCRIPTION
    The SQL script is split on GO statements, which must be by themselves on a line, e.g.

        select * from sys.tables
        GO

        select * from sys.views
        GO

    #>
    [CmdletBinding(DefaultParameterSetName='AsReader')]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The path to the SQL script to execute.
        $Path,

        [Parameter(Mandatory=$true,ParameterSetName='AsScalar')]
        [Switch]
        $AsScalar,
        
        [Parameter(Mandatory=$true,ParameterSetName='AsNonQuery')]
        [Switch]
        $NonQuery,
        
        [UInt32]
        # The time in seconds to wait for the command to execute. The default is 30 seconds.
        $CommandTimeout = 30
    )

    $invokeQueryArgs = @{ }
    if( $pscmdlet.ParameterSetName -eq 'AsScalar' )
    {
        $invokeQueryArgs.AsScalar = $true
    }
    elseif( $pscmdlet.ParameterSetName -eq 'AsNonQuery' )
    {
        $invokeQueryArgs.AsNonQuery = $true
    }
    
    if( -not ([IO.Path]::IsPathRooted( $Path )) )
    {
        $Path = Join-Path $DBMigrationsRoot $Path
    }
    
    Get-Content -Path $Path -Raw |
        Invoke-Query -CommandTimeout $CommandTimeout @invokeQueryArgs

}