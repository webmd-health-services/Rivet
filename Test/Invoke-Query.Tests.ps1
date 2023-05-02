
using module '..\Rivet'

#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'Invoke-Query' {
    BeforeEach {
        Start-RivetTest
        $script:session = New-RivetSession -ConfigurationPath $RTConfigFilePath
    }

    It 'can customize command timeout' {
        $failed = $false
        try
        {
            $script:session.CommandTimeout = 1
            $session = $script:session
            InModuleScope -ModuleName 'Rivet' {
                param(
                    [Object] $Session
                )

                Connect-Database -Session $Session -Name $Session.Databases.Name
                Invoke-Query -Session $Session -Query 'WAITFOR DELAY ''00:00:05'''
            } -ArgumentList $script:session
        }
        catch [Data.SqlClient.SqlException]
        {
            $failed = $true
        }

        $failed | Should -BeTrue
    }
}
