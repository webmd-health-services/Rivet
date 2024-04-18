
function Assert-Error
{
    param(
        [switch] $IsEmpty,

        [String] $MatchesRegex
    )

    if ($IsEmpty)
    {
        $Global:Error | Should -BeNullOrEmpty
    }

    if ($MatchesRegex)
    {
        $Global:Error | Should -Match $MatchesRegex
    }
}

Set-Alias -Name 'ThenError' -Value 'Assert-Error'