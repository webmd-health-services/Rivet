
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

    $trigger = Get-Trigger -SchemaName $SchemaName -Name $Name

    $expectedDefinition = $Definition

    $trigger | Should -Not -BeNullOrEmpty -Because ('Trigger ''{0}.{1}'' not found.' -f $SchemaName,$Name)

    if( $PSBoundParameters.ContainsKey('Definition') )
    {
        $trigger.definition | Should -Match ([Text.RegularExpressions.Regex]::Escape($expectedDefinition))
    }
}
