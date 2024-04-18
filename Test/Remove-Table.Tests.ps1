
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
    Remove-Item -Path 'alias:GivenMigration'
    Remove-Item -Path 'alias:ThenTable'

    $script:testDirPath = $null
    $script:testNum = 0
    $script:rivetJsonPath = $null
    $script:dbName = 'Remove-Table'

    function GivenMigration
    {
        param(
            [Parameter(Mandatory, Position=0)]
            [String] $Named,

            [Parameter(Mandatory, Position=1)]
            [String] $WithContent
        )

        $WithContent | New-TestMigration -Name $Named -ConfigFilePath $script:rivetJsonPath -DatabaseName $script:dbName
    }

    function ThenTable
    {
        param(
            [Parameter(Mandatory, Position=0)]
            [String] $Named,

            [String] $InSchema,

            [switch] $Not,

            [Parameter(Mandatory)]
            [switch] $Exists
        )

        $schemaArg = @{}
        if ($InSchema)
        {
            $schemaArg['SchemaName'] = $InSchema
        }

        $exists = Test-Table -Name $Named -DatabaseName $script:dbName @schemaArg
        if ($Not)
        {
            $exists | Should -BeFalse
        }
        else
        {
            $exists | Should -BeTrue
        }
    }

    function WhenPopping
    {
        Invoke-Rivet -Pop -ConfigFilePath $script:rivetJsonPath
    }

    function WhenPushing
    {
        Invoke-Rivet -Push -ConfigFilePath $script:rivetJsonPath
    }
}

Describe 'Remove-Table' {
    BeforeAll {
        Remove-RivetTestDatabase -Name $script:dbName
    }

    BeforeEach {
        $script:testDirPath = Join-Path -Path $TestDrive -ChildPath ($script:testNum++)
        New-Item -Path $script:testDirPath -ItemType Directory
        $script:rivetJsonPath = GivenRivetJsonFile -In $script:testDirPath -Database $script:dbName -PassThru
        $Global:Error.Clear()
    }

    AfterEach {
        Invoke-Rivet -Pop -All -Force -ConfigFilePath $script:rivetJsonPath
    }

    It 'should remove table' {
        GivenMigration 'AddTable' @'
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
'@
        WhenPushing
        ThenTable 'Ducati' -Exists

        WhenPopping
        ThenTable 'Ducati' -Not -Exists
    }

    It 'should remove table in custom schema' {
        GivenMigration 'AddTablesInDifferentSchemas' @'
    function Push-Migration()
    {
        Add-Table -Name 'Ducati' {
            Int 'ID' -Identity
        }
        Add-Schema -Name 'notDbo'

        Add-Table -Name 'DucatiNotDbo' {
            Int 'ID' -Identity
        } -SchemaName 'notDbo'
    }

    function Pop-Migration()
    {
        Remove-Table -Name 'DucatiNotDbo' -SchemaName 'notDbo'
        Remove-Table 'Ducati'
        Remove-Schema 'notDbo'
    }
'@

        WhenPushing

        ThenTable 'Ducati' -Exists
        ThenTable 'DucatiNotDbo' -InSchema 'notDbo' -Exists

        WhenPopping
        ThenTable 'Ducati' -Not -Exists
        ThenTable 'DucatiNotDbo' -InSchema 'notDbo' -Not -Exists
    }
}
