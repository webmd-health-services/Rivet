
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    function ThenNoErrors
    {
        $Global:Error | Should -BeNullOrEmpty
    }

    function WhenConnectingRivet
    {
        param(
            [String] $Database
        )

        $params = @{ }
        if( $Database )
        {
            $params['Database'] = $Database
        }

        Connect-RivetSession -Session $RTSession @params
    }
}

Describe 'Connect-RivetSession' {
    AfterEach {
        Stop-RivetTest
    }

    It 'should connect to specified database when given' {
        Start-RivetTest -PhysicalDatabase @($RTDatabaseName, $RTDatabase2Name)
        $RTSession.Connection.Database | Should -Be $RTDatabaseName
        $RTSession.CurrentDatabase.Name | Should -Be $RTDatabaseName

        WhenConnectingRivet -Database $RTDatabase2Name
        $RTSession.Connection.Database | Should -Be $RTDatabase2Name
        $RTSession.CurrentDatabase.Name | Should -Be $RTDatabase2Name

        ThenNoErrors
    }

    It 'should connect to the default database when no databases are given' {
        Start-RivetTest -PhysicalDatabase @($RTDatabaseName, $RTDatabase2Name)
        $RTSession.Connection.Database | Should -Be $RTDatabaseName
        $RTSession.CurrentDatabase.Name | Should -Be $RTDatabaseName

        WhenConnectingRivet
        $RTSession.Connection.Database | Should -Be $RTDatabaseName
        $RTSession.CurrentDatabase.Name | Should -Be $RTDatabaseName

        ThenNoErrors
    }

    It 'should return null after successfully connecting to a database' {
        Start-RivetTest -PhysicalDatabase @($RTDatabaseName, $RTDatabase2Name)
        $RTSession.Connection.Database | Should -Be $RTDatabaseName
        $RTSession.CurrentDatabase.Name | Should -Be $RTDatabaseName

        $result = WhenConnectingRivet -Database $RTDatabase2Name
        $RTSession.Connection.Database | Should -Be $RTDatabase2Name
        $RTSession.CurrentDatabase.Name | Should -Be $RTDatabase2Name

        $result | Should -BeNullOrEmpty
        ThenNoErrors
    }
}