<#
.SYNOPSIS
Runs the Rivet test suites.
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
# limitations under the License.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string[]]
    $Path,

    [Switch]
    $Recurse
)

#Requires -Version 4
Set-StrictMode -Version 'Latest'

# Let's get full stack traces in our errors.
$xmlLogPath = Split-Path -Qualifier -Path $PSScriptRoot
$xmlLogPath = Join-Path -Path $xmlLogPath -ChildPath 'BuildOutput\Rivet\CodeQuality\Rivet.blade.xml'
& (Join-Path -Path $PSScriptRoot -ChildPath '.\Tools\Blade\blade.ps1' -Resolve) -Path $Path -XmlLogPath $xmlLogPath -Recurse:$Recurse

$xmlLogPath = Join-Path -Path (Split-Path -Parent -Path $xmlLogPath) -ChildPath 'Rivet.pester.xml'
if( (Get-Module -Name 'Pester') )
{
    Remove-Module -Name 'Pester'
}
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Tools\Pester' -Resolve)
$result = Invoke-Pester -Script $Path -OutputFile $xmlLogPath -OutputFormat LegacyNUnitXml -PassThru |
                Select-Object -Last 1
$result
if( $result.FailedCount )
{
    Write-Error -Message ('{0} Pester tests failed. Check the NUnit reports for more details.' -f $result.FailedCount)
}
