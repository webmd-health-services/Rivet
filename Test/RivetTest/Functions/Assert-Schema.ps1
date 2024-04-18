
function Assert-Schema
{
    param(
        # The schema name.
        [Parameter(Mandatory)]
        [String] $Name,

        [String] $DatabaseName
    )

    Set-StrictMode -Version 'Latest'

    $schema = Get-Schema -Name $Name -DatabaseName $DatabaseName
    $schema | Should -Not -BeNullOrEmpty
}

