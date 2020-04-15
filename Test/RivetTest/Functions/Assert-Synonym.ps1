
function Assert-Synonym
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the synonym.
        $Name,

        [string]
        # The synonym's schema.
        $SchemaName = 'dbo',

        [string]
        # The base object name of what the synonym points to.
        $TargetObjectName
    )

    Set-StrictMode -Version 'Latest'

    $synonym = Get-Synonym -SchemaName $SchemaName -Name $Name

    if( (Test-Pester) )
    {
        $synonym | Should -Not -BeNullOrEmpty -Because ('Synonym ''{0}.{1}'' not found.' -f $SchemaName,$Name)

        if( $PSBoundParameters.ContainsKey('TargetObjectName') )
        {
            $synonym.base_object_name | Should -Be $TargetObjectName -Because ('Synonym {0}.{1}.base_object_name' -f $SchemaName,$Name)
        }
    }
    else
    {
        Assert-NotNull $synonym ('Synonym ''{0}.{1}'' not found.' -f $SchemaName,$Name)

        if( $PSBoundParameters.ContainsKey('TargetObjectName') )
        {
            Assert-Equal $TargetObjectName $synonym.base_object_name ('Synonym {0}.{1}.base_object_name' -f $SchemaName,$Name)
        }
    }    
}
