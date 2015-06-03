
function Assert-Schema
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The schema name.
        $Name,

        $DatabaseName
    )

    Assert-NotNull (Get-Schema -Name $Name -DatabaseName $DatabaseName)
}

