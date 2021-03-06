
function Assert-Schema
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The schema name.
        $Name,

        $DatabaseName
    )

    Set-StrictMode -Version 'Latest'

    $schema = Get-Schema -Name $Name -DatabaseName $DatabaseName
    if( (Test-Pester) )
    {
        $schema | Should -Not -BeNullOrEmpty
    }
    else
    {
        Assert-NotNull $schema
    }
}

