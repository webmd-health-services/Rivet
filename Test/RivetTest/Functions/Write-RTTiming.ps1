
function Write-RTTiming
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Message,

        [Switch]
        $Indent,

        [Switch]
        $Outdent
    )
 
    $Global:timingParameters = $PSBoundParameters

    try
    {
        InModuleScope -ModuleName 'Rivet' {
            Write-Timing @timingParameters
        }
    }
    finally
    {
        Remove-Variable -Name 'timingParameters' -Scope Global
    }
}