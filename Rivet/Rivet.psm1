
$Connection = New-Object Data.SqlClient.SqlConnection

$RivetSchemaName = 'rivet'
$RivetMigrationsTableName = 'Migrations'
$RivetMigrationsTableFullName = '{0}.{1}' -f $RivetSchemaName,$RivetMigrationsTableName
$RivetActivityTableName = 'Activity'

function Test-TypeDataMember
{
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The type name to check.
        $TypeName,

        [Parameter(Mandatory=$true)]
        [string]
        # The name of the member to check.
        $MemberName
    )

    Set-StrictMode -Version 'Latest'

    $typeData = Get-TypeData -TypeName $TypeName
    if( -not $typeData )
    {
        # The type isn't defined or there is no extended type data on it.
        return $false
    }

    return $typeData.Members.ContainsKey( $MemberName )
}

if( -not (Test-TypeDataMember -TypeName 'Rivet.OperationResult' -MemberName 'MigrationID') )
{
    Update-TypeData -TypeName 'Rivet.OperationResult' -MemberType ScriptProperty -MemberName 'MigrationID' -Value { $this.Migration.ID }
}

$functionRoot = Join-Path -Path $PSScriptRoot -ChildPath 'Functions' -Resolve
$columnRoot = Join-Path -Path $functionRoot -ChildPath 'Columns' -Resolve
$operationsRoot = Join-Path -Path $functionRoot -ChildPath 'Operations' -Resolve
@(
    $functionRoot,
    $operationsRoot,
    $columnRoot
) | 
    Get-ChildItem -Filter '*-*.ps1' |
    Where-Object { $_.BaseName -ne 'Export-Row' } |
    ForEach-Object { . $_.FullName }

$privateFunctions = @{
                        'Connect-Database' = $true;
                        'Convert-FileInfoToMigration' = $true;
                        'Disable-ForeignKey' = $true;
                        'Disconnect-Database' = $true;
                        'Enable-ForeignKey' = $true;
                        'Get-MigrationFile' = $true;
                        'Import-Plugin' = $true;
                        'Initialize-Database' = $true;
                        'Invoke-MigrationOperation' = $true;
                        'Invoke-Query' = $true;
                        'New-MigrationObject' = $true;
                        'Split-SqlBatchQuery' = $true;
                        'Test-Migration' = $true;
                        'Update-Database' = $true;
                        'Write-RivetError' = $true;
                     }
$publicFunctions = Invoke-Command -ScriptBlock {
                                                     @(
                                                            'Get-Migration',
                                                            'Get-RivetConfig',
                                                            'Invoke-Rivet'
                                                     )

                                                     Get-ChildItem -Path $operationsRoot,$functionRoot,$columnRoot -Filter '*.ps1' |
                                                        Select-Object -ExpandProperty 'BaseName'

                                               } |
                        Where-Object { -not $privateFunctions.ContainsKey( $_ ) }

Export-ModuleMember -Function $publicFunctions -Alias '*' -Cmdlet '*'
