
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

    $table = Get-Table -Name $Name -SchemaName $SchemaName

    if( (Test-Pester) )
    {
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
    else
    {
        Assert-NotNull $table ('table {0} not found' -f $Name) 

        if( $PSBoundParameters.ContainsKey('Description') )
        {
            Assert-Equal $Description $table.MSDescription ('table {0} MS_Description extended property' -f $Name)
        }

        if( $PSBoundParameters.ContainsKey('DataCompression') )
        {
            Assert-Equal $DataCompression $table.data_compression ('table {0} data compression option not set' -f $Name)
        }
    }
}

Set-Alias -Name 'ThenTable' -Value 'Assert-Table'