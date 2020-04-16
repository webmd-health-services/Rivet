
function Assert-WroteError
{
    param(
        [Parameter(Position=0)]
        [String]$Matching
    )

    Set-StrictMode -Version 'Latest'

    $Global:Error | Where-Object { $_ -match $Matching } | Should -Not -BeNullOrEmpty
}

Set-Alias -Name 'ThenWroteError' -Value 'Assert-WroteError'
