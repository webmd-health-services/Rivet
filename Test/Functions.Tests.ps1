
Set-StrictMode -Version 'Latest'
& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

Describe 'Rivet' {
    It 'exports all functions' {
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
                                'Invoke-Query' = $true;
                                'Initialize-Database' = $true;
                                'Invoke-MigrationOperation' = $true;
                                'New-TestMigration' = $true;
                                'New-MigrationObject' = $true;
                                'Split-SqlBatchQuery' = $true;
                                'Test-Migration' = $true;
                                'Test-Schema' = $true;
                                'Test-Table' = $true;
                                'Update-Database' = $true;
                                'Use-CallerPreference' = $true;
                                'Write-RivetError' = $true;
                             }
    
        $private = Invoke-Command -ScriptBlock {
                                                    Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath ..\Rivet\Functions) *-*.ps1
                                                    Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath ..\Rivet\Functions\Operations) *-*.ps1
                                               } |
                        Where-Object { -not $privateFunctions.ContainsKey( $_.BaseName ) } |
                        Where-Object { -not (Get-Command -Module Rivet -Name $_.BaseName -ErrorAction Ignore) } |
                        Sort-Object -Property BaseName
        $private | Should -BeNullOrEmpty
    
        $exposedFunctions = $privateFunctions.Keys |
                                Where-Object { (Get-Command -Module 'Rivet' -Name $_ -ErrorAction Ignore) }
        $exposedFunctions | Should -BeNullOrEmpty
    }
}
