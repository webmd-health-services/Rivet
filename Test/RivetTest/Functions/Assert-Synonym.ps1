
function Assert-Synonym
{
    param(
        # The name of the synonym.
        [Parameter(Mandatory=$true)]
        [String] $Name,

        # The synonym's schema.
        [String] $SchemaName = 'dbo',

        # The base object name of what the synonym points to.
        [String] $TargetObjectName,

        [String] $DatabaseName
    )

    Set-StrictMode -Version 'Latest'

    $synonym = Get-Synonym -SchemaName $SchemaName -Name $Name -DatabaseName $DatabaseName

    $synonym | Should -Not -BeNullOrEmpty -Because ('Synonym ''{0}.{1}'' not found.' -f $SchemaName,$Name)

    if( $PSBoundParameters.ContainsKey('TargetObjectName') )
    {
        $synonym.base_object_name | Should -Be $TargetObjectName -Because ('Synonym {0}.{1}.base_object_name' -f $SchemaName,$Name)
    }
}
