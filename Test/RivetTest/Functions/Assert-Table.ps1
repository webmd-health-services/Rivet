
function Assert-Table
{
    param(
        $Name,

        [String]$SchemaName = 'dbo',

        $Description,

        [int]$DataCompression,

        [switch]$Not,

        [switch]$Exists
    )

    Set-StrictMode -Version Latest

    $table = Get-Table -Name $Name -SchemaName $SchemaName | Select-Object -First 1

    if( $Not -and $Exists )
    {
        $table | Should -BeNullOrEmpty -Because "table [$($SchemaName)].[$($Name)] was created but should not exist"
        return
    }

    $table | Should -Not -BeNullOrEmpty
    if( $PSBoundParameters.ContainsKey('Description') )
    {
        $table.MSDescription | Should -Be $Description
    }

    if( $PSBoundParameters.ContainsKey('DataCompression') )
    {
        $table.data_compression | Should -Be $DataCompression
    }
}

Set-Alias -Name 'ThenTable' -Value 'Assert-Table'