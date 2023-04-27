
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Remove-Table' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should remove table' {
        @'
    function Push-Migration()
    {
        Add-Table -Name 'Ducati' {
            Int 'ID' -Identity
        } # -SchemaName

    }

    function Pop-Migration()
    {
        Remove-Table -Name 'Ducati'
    }
'@ | New-TestMigration -Name 'AddTable'
        Invoke-RTRivet -Push 'AddTable'
        (Test-Table 'Ducati') | Should -BeTrue

        Invoke-RTRivet -Pop ([Int32]::MaxValue)
        (Test-Table 'Ducati') | Should -BeFalse
    }

    It 'should remove table in custom schema' {
        $Name = 'Ducati'
        $CustomSchemaName = 'notDbo'

    @'
    function Push-Migration()
    {
        Add-Table -Name 'Ducati' {
            Int 'ID' -Identity
        }
        Add-Schema -Name 'notDbo'

        Add-Table -Name 'Ducati' {
            Int 'ID' -Identity
        } -SchemaName 'notDbo'
    }

    function Pop-Migration()
    {
        Remove-Table -Name 'Ducati' -SchemaName 'notDbo'
        Remove-Table 'Ducati'
        Remove-Schema 'notDbo'
    }
'@ | New-TestMigration -Name 'AddTablesInDifferentSchemas'

        Invoke-RTRivet -Push 'AddTablesInDifferentSchemas'

        (Test-Table -Name $Name) | Should -BeTrue
        (Test-Table -Name $Name -SchemaName $CustomSchemaName) | Should -BeTrue

        Invoke-RTRivet -Pop ([Int32]::MaxValue)
        (Test-Table -Name $Name) | Should -BeFalse
        (Test-Table -Name $Name -SchemaName $CustomSchemaName) | Should -BeFalse
    }
}
