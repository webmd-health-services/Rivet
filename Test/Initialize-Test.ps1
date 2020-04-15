
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

if( (Get-Module -Name 'RivetSamples') )
{
    Remove-Module 'RivetSamples' -Force
}

if( (Test-Path -Path 'function:Watch-Operation') )
{
    Remove-Item -Path 'function:Watch-Operation'
}