
function Assert-Schema
{
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The schema name.
        $Name
    )

    Assert-NotNull (Get-Schema -Name $Name)
}

