
function Start-Test
{
    & (Join-Path -Path $TestDir -ChildPath ..\Rivet\Import-Rivet.ps1 -Resolve)
}

function Stop-Test
{
}

function Test-FunctionsExported
{
    $privateFunctions = @{
                            'Connect-Database' = $true;
                            'Disconnect-Database' = $true;
                            'Enable-ForeignKey' = $true;  #OBSOLETE
                            'Disable-ForeignKey' = $true; #OBSOLETE
                            'Export-Row' = $true;
                            'Get-MigrationFile' = $true;
                            'Convert-FileInfoToMigration' = $true;
                            'Get-MigrationScript' = $true;
                            'Import-Rivet' = $true;
                            'Import-Plugin' = $true;
                            'Invoke-Query' = $true;
                            'Initialize-Database' = $true;
                            'Invoke-MigrationOperation' = $true;
                            'New-Migration' = $true;
                            'New-MigrationObject' = $true;
                            'Split-SqlBatchQuery' = $true;
                            'Test-Migration' = $true;
                            'Test-Schema' = $true;
                            'Test-Table' = $true;
                            'Update-Database' = $true;
                            'Write-RivetError' = $true;
                         }

    $private = Invoke-Command -ScriptBlock {
                                                Get-ChildItem -Path (Join-Path -Path $TestDir -ChildPath ..\Rivet\Functions) *-*.ps1
                                                Get-ChildItem -Path (Join-Path -Path $TestDir -ChildPath ..\Rivet\Functions\Operations) *-*.ps1
                                           } |
                    Where-Object { -not $privateFunctions.ContainsKey( $_.BaseName ) } |
                    Where-Object { -not (Get-Command -Module Rivet -Name $_.BaseName -ErrorAction Ignore) } |
                    Sort-Object -Property BaseName
    Assert-Null $private ('These functions are not public.  Please update Rivet.psm1 to include these functions in the export list, or add them to the list of private functions in this test.')

    $exposedFunctions = $privateFunctions.Keys |
                            Where-Object { (Get-Command -Module 'Rivet' -Name $_ -ErrorAction Ignore) }
    Assert-Null $exposedFunctions ('These functions are private but visible.')
}

function Test-ShouldExportCustomOperations
{
    $operationPath = Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\Functions\Operations\Add-MyOperation.ps1'
    New-Item -Path $operationPath -ItemType 'File'

    @'
function Add-MyOperation
{
}
'@ | Set-Content -Path $operationPath
    try
    {
        if( (Get-Module -Name 'Rivet') )
        {
            Remove-Module -Name 'Rivet' -Force
        }
        Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\Rivet.psd1' -Resolve)
        Assert-True (Get-Command -Name 'Add-MyOperation' -Module 'Rivet')
    }
    finally
    {
        Remove-Item -Path $operationPath
    }

}
