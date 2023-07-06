
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
    $schema | Should -Not -BeNullOrEmpty
}

