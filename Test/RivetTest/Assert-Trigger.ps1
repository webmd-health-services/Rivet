
function Assert-Trigger
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the trigger.
        $Name,

        [string]
        # The schema of the trigger.
        $SchemaName = 'dbo',

        [string]
        # The expected trigger definition.
        $Definition
    )

    Set-StrictMode -Version 'Latest'

    $trigger = Get-SysObject -SchemaName $SchemaName -Name $Name -Type 'TR'
    Assert-NotNull $trigger ('Trigger ''{0}.{1}'' not found.' -f $SchemaName,$Name)

    if( $PSBoundParameters.ContainsKey('Definition') )
    {
        $expectedDefinition = $Definition
        Assert-Match $trigger.definition ([Text.RegularExpressions.Regex]::Escape($expectedDefinition))
    }
}
