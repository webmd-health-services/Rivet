
function Test-MSSqlExtendedProperty
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Rivet_Session] $Session,

        [Parameter(Mandatory, ParameterSetName='ForSchema')]
        [Parameter(ParameterSetName='ForTable')]
        [Parameter(ParameterSetName='ForTableColumn')]
        [Parameter(ParameterSetName='ForView')]
        [Parameter(ParameterSetName='ForViewColumn')]
        [String] $SchemaName,

        [Parameter(Mandatory, ParameterSetName='ForTable')]
        [Parameter(Mandatory, ParameterSetName='ForTableColumn')]
        [String] $TableName,

        [Parameter(Mandatory, ParameterSetName='ForTableColumn')]
        [Parameter(Mandatory, ParameterSetName='ForViewColumn')]
        [String] $ColumnName,

        [Parameter(Mandatory, ParameterSetName='ForView')]
        [Parameter(Mandatory, ParameterSetName='ForViewColumn')]
        [String] $ViewName,

        [Object] $Name,

        [Parameter(Mandatory, ParameterSetName='RawL0')]
        [Parameter(Mandatory, ParameterSetName='RawL1')]
        [Parameter(Mandatory, ParameterSetName='RawL2')]
        [AllowNull()]
        [Object] $Level0Type,

        [Parameter(Mandatory, ParameterSetName='RawL0')]
        [Parameter(Mandatory, ParameterSetName='RawL1')]
        [Parameter(Mandatory, ParameterSetName='RawL2')]
        [AllowNull()]
        [Object] $Level0Name,

        [Parameter(Mandatory, ParameterSetName='RawL1')]
        [Parameter(Mandatory, ParameterSetName='RawL2')]
        [AllowNull()]
        [Object] $Level1Type,

        [Parameter(Mandatory, ParameterSetName='RawL1')]
        [Parameter(Mandatory, ParameterSetName='RawL2')]
        [AllowNull()]
        [Object] $Level1Name,

        [Parameter(Mandatory, ParameterSetName='RawL2')]
        [AllowNull()]
        [Object] $Level2Type,

        [Parameter(Mandatory, ParameterSetName='RawL2')]
        [AllowNull()]
        [Object] $Level2Name
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

    $PSBoundParameters['ErrorAction'] = [Management.Automation.ActionPreference]::Ignore
    if (Get-MSSqlExtendedProperty @PSBoundParameters)
    {
        return $true
    }

    return $false
}
