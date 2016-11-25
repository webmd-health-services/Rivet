<#
.SYNOPSIS
Chocolately install script for Silk.
#>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.[CmdletBinding()]

param(
)

#Requires -Version 4
Set-StrictMode -Version 'Latest'
$ErrorActionPreference = 'Stop'

$moduleName = 'Rivet'

$errorCount = $Global:Error.Count
Write-Verbose -Message ('Error Count: {0}' -f $errorCount)
try
{
    $env:PSModulePath -split ';' |
        Where-Object { $_ } | 
        Join-Path -ChildPath $moduleName |
        Where-Object { Test-Path -Path $_ -PathType Container } |
        Rename-Item -NewName { '{0}{1}' -f $moduleName,[IO.Path]::GetRandomFileName() } -PassThru |
        Remove-Item -Recurse -Force
}
finally
{
    Write-Verbose -Message ('Error Count: {0}' -f $Global:Error.Count)
    for( $idx = $errorCount; $idx -lt $Global:Error.Count; ++$idx )
    {
        $Global:Error[$idx - $errorCount]
        $Global:Error[$idx - $errorCount] | Format-List -Property '*' -Force | Out-String | Write-Verbose -Verbose
    }
}