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
    [string[]]
    $Path,

    [Switch]
    $Recurse
)

#Requires -Version 4
Set-StrictMode -Version 'Latest'

.\init.ps1

if( -not $Path )
{
    $Path = Join-Path -Path $PSScriptRoot -ChildPath 'Test' -Resolve
}

$failed = $false

$xmlLogPath = Join-Path -Path $PSScriptRoot -ChildPath 'Output'
Install-Directory -Path $xmlLogPath
$nunitLogPath = Join-Path -Path $xmlLogPath -ChildPath 'nunit.xml'

$nunitPath = Join-Path -Path $PSScriptRoot -ChildPath 'packages\NUnit.ConsoleRunner\tools\nunit3-console.exe' -Resolve
& $nunitPath (Join-Path -Path $PSScriptRoot -ChildPath 'Source\Test\bin\*\Rivet.Test.dll' -Resolve) "--result=$nunitLogPath;format=nunit2"
( $LASTEXITCODE -ne 0 )
{
    Write-Error -Message ('{0} NUnit tests failed. Check the build reports for more details.' -f $LASTEXITCODE)
    $failed = $true
}

# Let's get full stack traces in our errors.
$bladeLogPath = Join-Path -Path $xmlLogPath -ChildPath 'blade.xml'
& (Join-Path -Path $PSScriptRoot -ChildPath '.\Tools\Blade\blade.ps1' -Resolve) -Path $Path -XmlLogPath $bladeLogPath -Recurse:$Recurse
if( $LastBladeResult.Failures -or $LastBladeResult.Errors )
{
    Write-Error -Message ('{0} Blade tests failed, and {1} tests had errors. Check the build reports for more details.' -f $LastBladeResult.Failures,$LastBladeResult.Errors)
    $failed = $true
}

$pesterLogPath = Join-Path -Path (Split-Path -Parent -Path $xmlLogPath) -ChildPath 'pester.xml'
if( (Get-Module -Name 'Pester') )
{
    Remove-Module -Name 'Pester'
}
Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Pester' -Resolve)
$result = Invoke-Pester -Script $Path -OutputFile $pesterLogPath -OutputFormat LegacyNUnitXml -PassThru |
                Select-Object -Last 1
$result
if( $result.FailedCount )
{
    Write-Error -Message ('{0} Pester tests failed. Check the NUnit reports for more details.' -f $result.FailedCount)
    $failed = $true
}

if( $failed )
{
    exit 1
}
