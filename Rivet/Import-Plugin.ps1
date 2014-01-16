
function Import-Plugin
{
    <#
    .SYNOPSIS
    Loads any plugins.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        # The path to load the plugins from.
        $Path
    )

    Set-StrictMode -Version 'Latest'

    if( -not (Test-Path -Path $Path -PathType Container) )
    {
        Write-Error ('Plugin path ''{0}'' not found.' -f $Path)
        return
    }

    # Load known plug-ins.
    $knownPlugins = @( 'Start-MigrationOperation', 'Complete-MigrationOperation' )

    $knownPlugins | 
        ForEach-Object { Join-Path -Path 'function:' -ChildPath $_ } |
        Where-Object { Test-Path -Path $_ } |
        Remove-Item -WhatIf:$false
    
    $expectedFunctions = @()
    Get-ChildItem -Path $Path -Filter '*.ps1' -File |
        ForEach-Object { 
            $expectedFunctions += $_
            . $_.FullName 
            Join-Path -Path 'function:' -ChildPath $_.BaseName
        } |
        Where-Object { Test-Path -Path $_ } |
        Get-Item |
        ForEach-Object {

            $_ | Remove-Item -WhatIf:$false

            # Re-create the function in script scope.
            Invoke-Expression -Command @"
function script:$($_.Name)
{
$($_.Definition)
}
"@
        }

        $expectedFunctions |
            ForEach-Object { 
                $functionPath = Join-Path -Path 'function:' -ChildPath $_.BaseName
                if( -not (Test-Path -Path $functionPath) )
                {
                    Write-Error ('Plugin ''{0}'' not found. Expected file ''{1}'' to implement function ''{0}''.' -f $_.BaseName,$_.FullName)
                }
            }
}
