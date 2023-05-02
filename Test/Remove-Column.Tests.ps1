
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Remove-Column' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should remove columns' {
        @'
function Push-Migration()
{
    Add-Schema 'My-Schema'

    Add-Table -SchemaName 'My-Schema' AddColumnNoDefaultsAllNull {
        Int 'id' -Identity
        VarChar 'varchar' -Size 50
        VarChar 'varcharmax' -Max
    }

    $tableParam = @{ TableName = 'AddColumnNoDefaultsAllNull' }
    Update-Table -SchemaName 'My-Schema' 'AddColumnNoDefaultsAllNull' -Remove 'varchar','varcharmax'
}

function Pop-Migration()
{
    Remove-Table -SchemaName 'My-Schema' 'AddColumnNoDefaultsAllNull'
    Remove-Schema 'My-Schema'
}
'@ | New-TestMigration -Name 'AddColumnNoDefaultsAllNull'

        Invoke-RTRivet -Push 'AddColumnNoDefaultsAllNull'

        $commonArgs = @{ TableName = 'AddColumnNoDefaultsAllNull' ; SchemaName = 'My-Schema' }
            (Test-Column -Name 'varchar' @commonArgs) | Should -BeFalse
            (Test-Column -Name 'varcharmax' @commonArgs) | Should -BeFalse
    }
}
