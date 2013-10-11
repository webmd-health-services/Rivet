
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
                            'Get-MigrationScript' = $true;
                            'Get-RivetConfig' = $true;
                            'Import-Rivet' = $true;
                            'Initialize-Database' = $true;
                            'Invoke-Migration' = $true;
                            'Invoke-MigrationEvent' = $true;
                            'New-Migration' = $true;
                            'New-MigrationObject' = $true;
                            'Resolve-ObjectScriptPath' = $true;
                            'Test-Migration' = $true;
                            'Test-Schema' = $true;
                            'Test-Table' = $true;
                            'Update-Database' = $true;
                            'Write-RivetError' = $true;
                            '_Get-Migration' = $true;
                         }

    $private = Get-ChildItem -Path (Join-Path -Path $TestDir -ChildPath ..\Rivet) *-*.ps1 |
                    Where-Object { -not $privateFunctions.ContainsKey( $_.BaseName ) } |
                    Where-Object { -not (Get-Command -Module Rivet -Name $_.BaseName -ErrorAction Ignore) } |
                    Sort-Object -Property BaseName
    Assert-Null $private ('These functions are not public.  Please update Rivet.psm1 to include these functions in the export list, or add them to the list of private functions in this test.')
}