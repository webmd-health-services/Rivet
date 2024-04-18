
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
    Remove-Item -Path 'alias:GivenMigration'

    $script:pluginModuleName = 'GetMigrationPlugins'
    $script:pluginModulePath = '{0}\{0}.psm1' -f $script:pluginModuleName
    $script:migrations = $null
    $script:rivetJsonPath = $null
    $script:testDir = $null
    $script:testNum = 0
    $script:dbName = 'Get-Migration'

    $script:noOpMigration = @'
    function Push-Migration
    {
        Invoke-Ddl 'select 1'
    }

    function Pop-Migration
    {
        Invoke-Ddl 'select 1'
    }
'@

    function Assert-GetMigration
    {
        param(
            [Rivet.Migration]
            $m
        )

        Set-StrictMode -Version 'Latest'
        $Global:Error | Should -BeNullOrEmpty
        $m | Should -Not -BeNullOrEmpty
        $m | Should -BeOfType ([Rivet.Migration])
        $m.Name | Should -Be 'ShouldGetMigrationsUsingCurrentRivetJsonFile'

        $m.PushOperations.Count | Should -Be 1
        $pushOp = $m.PushOperations[0]
        $pushOp | Should -BeOfType ([Rivet.Operations.AddSchemaOperation])
        $pushOp.Name | Should -Be 'ShouldGetMigrationsUsingCurrentRivetJsonFile'

        $m.PopOperations.Count | Should -Be 1
        $popOp = $m.PopOperations[0]
        $popOp | Should -BeOfType ([Rivet.Operations.RemoveSchemaOperation])
        $popOp.Name | Should -Be 'ShouldGetMigrationsUsingCurrentRivetJsonFile'
    }

    function GivenMigration
    {
        param(
            [Parameter(Mandatory, Position=0)]
            [String] $Named,

            [Parameter(Mandatory, Position=1)]
            [String] $WithContent
        )

        $WithContent |
            New-TestMigration -Named $Named -DatabaseName $script:dbName -ConfigFilePath $script:rivetJsonPath
    }

    function GivenPlugin
    {
        [CmdletBinding()]
        param(
            [String] $WithContent
        )

        GivenFile $script:pluginModulePath -In $script:testDir $WithContent
    }

    function WhenGettingMigrations
    {
        [CmdletBinding()]
        param(
        )

        $script:migrations = Get-Migration -ConfigFilePath $script:rivetJsonPath
    }
}

Describe 'Get-Migration' {
    BeforeEach {
        $script:testDir = Join-Path -Path $TestDrive -ChildPath ($script:testNum++)
        New-Item -Path $script:testDir -ItemType Directory
        $Global:Error.Clear()
        $script:migrations = @()
        $script:rivetJsonPath = GivenRivetJsonFile -In $script:testDir -Database $script:dbName -PassThru
    }

    Context 'minimal configuration' {
        BeforeEach {
            $script:rivetJsonPath = GivenRivetJsonFile -In $script:testDir -Database $script:dbName -PassThru
        }

        It 'should get migrations using current rivet json file' {
            GivenMigration 'ShouldGetMigrationsUsingCurrentRivetJsonFile' @'
                function Push-Migration
                {
                    Add-Schema 'ShouldGetMigrationsUsingCurrentRivetJsonFile'
                }

                function Pop-Migration
                {
                    Remove-Schema 'ShouldGetMigrationsUsingCurrentRivetJsonFile'
                }
'@

            Push-Location -Path $script:testDir -StackName $PSCommandPath
            try
            {
                Assert-GetMigration (Get-Migration)
                Assert-GetMigration (Get-Migration -Database $script:dbName -ConfigFilePath $script:rivetJsonPath)
                $Global:Error | Should -BeNullOrEmpty
            }
            finally
            {
                Pop-Location -StackName $PSCommandPath
            }

            # Now, use an explicit path.
            Assert-GetMigration (Get-Migration -ConfigFilePath $script:rivetJsonPath)
        }

        It 'should protect against items returned from pipeline' {
            GivenMigration 'ShouldProtectAgainstItemsReturnedFromPipeline' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }
                1 # See that guy? We should protect ourselves against 💩 like that.
                function Pop-Migration
                {
                    Invoke-Ddl 'select 1'
                }
'@

            $m = Get-Migration -ConfigFilePath $script:rivetJsonPath
            $Global:Error | Should -BeNullOrEmpty
            $m | Should -BeOfType ([Rivet.Migration])
        }

        It 'should ignore migration with empty push' {
            GivenMigration 'EmptyPush' @'
                function Push-Migration
                {
                    # I'm empty.
                }

                function Pop-Migration
                {
                    Invoke-Ddl 'select 1'
                }
'@

            $result = Get-Migration -ConfigFilePath $script:rivetJsonPath -ErrorAction SilentlyContinue
            $result | Should -BeNullOrEmpty
            $Global:Error | Should -BeNullOrEmpty
        }

        It 'should ignore migration with empty pop' {
            GivenMigration 'EmptyPop' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }

                function Pop-Migration
                {
                    # I'm empty.
                }
'@

            $result = Get-Migration -ConfigFilePath $script:rivetJsonPath -ErrorAction SilentlyContinue
            $result | Should -BeNullOrEmpty
            $Global:Error | Should -BeNullOrEmpty
        }

        It 'should reject migration with no push migration function' {
            GivenMigration 'MissingPush' @'
                function Pop-Migration
                {
                    Invoke-Ddl 'select 1'
                }
'@

            $result =
                { Get-Migration -ConfigFilePath $script:rivetJsonPath } |
                Should -Throw '*Push-Migration function not found*'
            $result | Should -BeNullOrEmpty
            $Global:Error.Count | Should -BeGreaterThan 0
            $Global:Error[0] | Should -Match 'Push-Migration.*not found'
        }

        It 'should reject migration with no pop migration function' {
            GivenMigration 'MissingPop' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }
'@

            $result =
                { Get-Migration -ConfigFilePath $script:rivetJsonPath } |
                Should -Throw '*Pop-Migration function not found*'
            $result | Should -BeNullOrEmpty
            $Global:Error.Count | Should -BeGreaterThan 0
            $Global:Error[0] | Should -Match 'Pop-Migration.*not found'
        }

        It 'should write an error if included migration not found' {
            { Get-Migration -ConfigFilePath $script:rivetJsonPath -Include 'nomigrationbythisname' } |
                Should -Throw "*""nomigrationbythisname""*does not exist*"
        }

        It 'should not write an error if included wildcarded migration not found' {
            $result = Get-Migration -ConfigFilePath $script:rivetJsonPath -Include '*fubar*'
            $result | Should -BeNullOrEmpty
            $Global:Error | Should -BeNullOrEmpty
        }

        It 'should include migration by name or ID' {
            $m = GivenMigration 'ShouldIncludeMigrationByNameOrID' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }

                function Pop-Migration
                {
                    Invoke-Ddl 'select 1'
                }
'@

            $id = ($m.BaseName -split '_')[0]

            $result = Get-Migration -ConfigFilePath $script:rivetJsonPath -Include 'ShouldIncludeMigrationByNameOrID'
            $result | Should -Not -BeNullOrEmpty
            $id | Should -Be $result.ID
            'ShouldIncludeMigrationByNameOrID' | Should -Be $result.Name
            $m.BaseName | Should -Be $result.FullName

            $result = Get-Migration -ConfigFilePath $script:rivetJsonPath -Include $id
            $result | Should -Not -BeNullOrEmpty
            $id | Should -Be $result.ID
            'ShouldIncludeMigrationByNameOrID' | Should -Be $result.Name
            $m.BaseName | Should -Be $result.FullName
        }

        It 'should include migration wildcard ID' {
            $m = GivenMigration 'ShouldIncludeMigrationWildcardID' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }

                function Pop-Migration
                {
                    Invoke-Ddl 'select 1'
                }
'@

            $id = ($m.BaseName -split '_')[0]

            $result = Get-Migration -ConfigFilePath $script:rivetJsonPath -Include ('{0}*' -f $id.Substring(0,10))
            $result | Should -Not -BeNullOrEmpty
            $id | Should -Be $result.ID
            'ShouldIncludeMigrationWildcardID' | Should -Be $result.Name
            $m.BaseName | Should -Be $result.FullName
        }

        It 'should get a migration by base name' {
            $m = GivenMigration 'ShouldGetAMigrationByBaseName' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }

                function Pop-Migration
                {
                    Invoke-Ddl 'select 1'
                }
'@

            $id = ($m.BaseName -split '_')[0]

            $result = Get-Migration -ConfigFilePath $script:rivetJsonPath -Include $m.BaseName
            $result | Should -Not -BeNullOrEmpty
            $id | Should -Be $result.ID
            'ShouldGetAMigrationByBaseName' | Should -Be $result.Name
            $m.BaseName | Should -Be $result.FullName
        }

        It 'should get a migration by base name with wildcard' {
            $m = GivenMigration 'ShouldGetAMigrationByBaseNameWithWildcard' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }

                function Pop-Migration
                {
                    Invoke-Ddl 'select 1'
                }
'@

            $id = ($m.BaseName -split '_')[0]

            $result = Get-Migration -ConfigFilePath $script:rivetJsonPath -Include ('{0}*' -f $m.BaseName.Substring(0,20))
            $result | Should -Not -BeNullOrEmpty
            $id | Should -Be $result.ID
            'ShouldGetAMigrationByBaseNameWithWildcard' | Should -Be $result.Name
            $m.BaseName | Should -Be $result.FullName
        }

        It 'should match exclude pattern against ID, name, and base name and support wildcards' {
            $m = GivenMigration 'ShouldExcludeMigrationByNameOrID' $script:noOpMigration
            $id = ($m.BaseName -split '_')[0]

            GivenMigration 'ShouldInclude' $script:noOpMigration
            GivenMigration 'ShouldExcludeIfUsingWildcards' $script:noOpMigration

            # When excluding a specific migration by name.
            Get-Migration -ConfigFilePath $script:rivetJsonPath -Exclude 'ShouldExcludeMigrationByNameOrID' | Should -HaveCount 2
            Get-Migration -ConfigFilePath $script:rivetJsonPath -Exclude 'ShouldExclude*'  | Should -HaveCount 1

            # Should match against base name.
            Get-Migration -ConfigFilePath $script:rivetJsonPath -Exclude $m.BaseName | Should -HaveCount 2
            Get-Migration -ConfigFilePath $script:rivetJsonPath -Exclude "$($id.Substring(0, 4))*_ShouldExcludeMig*" | Should -HaveCount 2

            # Should match against ID.
            Get-Migration -ConfigFilePath $script:rivetJsonPath -Exclude $id | Should -HaveCount 2
            Get-Migration -ConfigFilePath $script:rivetJsonPath -Exclude "$($id.Substring(0, 4))*" | Should -BeNullOrEmpty

            # should match multiple exclude patterns
            Get-Migration -ConfigFilePath $script:rivetJsonPath -Exclude '*Wildcards','*ID' | Should -HaveCount 1

            $Global:Error | Should -BeNullOrEmpty
        }
    }

    Context 'CommandTimeout' {
        It 'should set timeout duration to default 30 seconds on Rivet operations when CommandTimeout isn''t specified in the Rivet configuration' {
            GivenMigration 'SetCommandTimeout' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }
                function Pop-Migration
                {
                    Invoke-Ddl 'select 1'
                }
'@

            $m = Get-Migration -ConfigFilePath $script:rivetJsonPath
            $Global:Error | Should -BeNullOrEmpty
            $m | Should -BeOfType ([Rivet.Migration])
            $m.PopOperations[0].CommandTimeout | Should -Be 30
            $m.PushOperations[0].CommandTimeout | Should -Be 30
        }

        It 'should set timeout duration on Rivet operations when CommandTimeout is specified in the Rivet configuration' {
            $script:rivetJsonPath =
                GivenRivetJsonFile -In $script:testDir -Database $script:dbName -PassThru -CommandTimeout 60

            GivenMigration 'SetCommandTimeout' @'
            function Push-Migration
            {
                Invoke-Ddl 'select 1'
            }
            function Pop-Migration
            {
                Invoke-Ddl 'select 1'
            }
'@

            $m = Get-Migration -ConfigFilePath $script:rivetJsonPath
            $Global:Error | Should -BeNullOrEmpty
            $m | Should -BeOfType ([Rivet.Migration])
            $m.PopOperations[0].CommandTimeout | Should -Be 60
            $m.PushOperations[0].CommandTimeout | Should -Be 60
        }
    }

    Context 'Plugins' {
        BeforeEach {
            $script:rivetJsonPath = GivenRivetJsonFile -In $script:testDir `
                                                       -Database $script:dbName `
                                                       -PluginPath $script:pluginModuleName `
                                                       -PassThru
        }

        AfterEach {
            if ((Get-Module $script:pluginModuleName))
            {
                Remove-Module $script:pluginModuleName
            }
        }

        It 'should run the plugin' {
            GivenPlugin @'
                function OnAdd
                {
                    [Rivet.Plugin([Rivet.Events]::BeforeOperationLoad)]
                    param(
                        $Migration,
                        $Operation
                    )

                    Add-Schema 'boom'
                }
'@
            GivenMigration 'One' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }
                function Pop-Migration
                {
                    Invoke-Ddl 'select 2'
                }
'@
            WhenGettingMigrations
            $script:migrations | Should -Not -BeNullOrEmpty
            $script:migrations.PushOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -Not -BeNullOrEmpty
            $script:migrations.PushOperations[1] | Should -BeOfType ([Rivet.Operations.RawDdlOperation])
            $script:migrations.PopOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -Not -BeNullOrEmpty
            $script:migrations.PopOperations[1] | Should -BeOfType ([Rivet.Operations.RawDdlOperation])
        }

        It ('should run all the plugins') {
            GivenPlugin @'
                function OnAdd
                {
                    [Rivet.Plugin([Rivet.Events]::BeforeOperationLoad)]
                    param(
                        $Migration,
                        $Operation
                    )

                    Add-Schema 'boom'
                }

                function AnotherOnAdd
                {
                    [Rivet.Plugin([Rivet.Events]::BeforeOperationLoad)]
                    param(
                        $Migration,
                        $Operation
                    )

                    Add-Schema 'boom'
                }
'@
            GivenMigration 'One' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }
                function Pop-Migration
                {
                    Invoke-Ddl 'select 2'
                }
'@
            WhenGettingMigrations
            $script:migrations | Should -Not -BeNullOrEmpty
            $script:migrations.PushOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -HaveCount 2
            $script:migrations.PopOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -HaveCount 2
        }

        It 'runs before operation load plugins' {
            GivenPlugin @'
                function OnAdd
                {
                    [Rivet.Plugin([Rivet.Events]::BeforeOperationLoad)]
                    param(
                        $Operation
                    )

                    Add-Schema -Name 'Fubar'
                }
'@
            GivenMigration 'One' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }
                function Pop-Migration
                {
                    Invoke-Ddl 'select 2'
                }
'@
            { WhenGettingMigrations } |
                Should -Throw '*"BeforeOperationLoad" event must have a named "Migration" parameter*'
            $script:migrations | Should -BeNullOrEmpty
        }

        It 'ignores objects returned by plugin' {
            GivenPlugin @'
                function BeforeOpLoad
                {
                    [Rivet.Plugin([Rivet.Events]::BeforeOperationLoad)]
                    param(
                        $Migration,
                        $Operation
                    )

                    return 'BeforeOperationLoad'
                }

                function AfterOpLoad
                {
                    [Rivet.Plugin([Rivet.Events]::AfterOperationLoad)]
                    param(
                        $Migration,
                        $Operation
                    )

                    return 'AfterOperationLoad'
                }

                function AfterMigrationLoad
                {
                    [Rivet.Plugin([Rivet.Events]::BeforeOperationLoad)]
                    [Rivet.Plugin([Rivet.Events]::AfterOperationLoad)]
                    [Rivet.Plugin([Rivet.Events]::AfterMigrationLoad)]
                    param(
                        $Migration,
                        $Operation
                    )

                    return 'AfterMigrationLoad'
                }
'@
            GivenMigration 'One' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }
                function Pop-Migration
                {
                    Invoke-Ddl 'select 2'
                }
'@
            { WhenGettingMigrations } | Should -Not -Throw
        }

        It ('should fail') {
            GivenPlugin @'
                function OnAdd
                {
                    [Rivet.Plugin([Rivet.Events]::BeforeOperationLoad)]
                    param(
                        $Migration
                    )

                    Add-Schema -Name 'Fubar'
                }
'@
            GivenMigration 'One' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }
                function Pop-Migration
                {
                    Invoke-Ddl 'select 2'
                }
'@
            { WhenGettingMigrations } |
                Should -Throw '*"BeforeOperationLoad" event must have a named "Operation" parameter*'
            $script:migrations | Should -BeNullOrEmpty
        }

        It ('should run the plugin') {
            GivenPlugin @'
                function OnAdd
                {
                    [Rivet.Plugin([Rivet.Events]::AfterOperationLoad)]
                    param(
                        $Migration,
                        $Operation
                    )

                    Add-Schema 'boom'
                }
'@
            GivenMigration 'One' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }
                function Pop-Migration
                {
                    Invoke-Ddl 'select 2'
                }
'@
            WhenGettingMigrations
            $script:migrations | Should -Not -BeNullOrEmpty
            $script:migrations.PushOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -Not -BeNullOrEmpty
            $script:migrations.PushOperations[0] | Should -BeOfType ([Rivet.Operations.RawDdlOperation])
            $script:migrations.PopOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -Not -BeNullOrEmpty
            $script:migrations.PopOperations[0] | Should -BeOfType ([Rivet.Operations.RawDdlOperation])
        }

        It ('should run all the plugins') {
            GivenPlugin @'
                function OnAdd
                {
                    [Rivet.Plugin([Rivet.Events]::AfterOperationLoad)]
                    param(
                        $Migration,
                        $Operation
                    )

                    Add-Schema 'boom'
                }

                function AnotherOnAdd
                {
                    [Rivet.Plugin([Rivet.Events]::AfterOperationLoad)]
                    param(
                        $Migration,
                        $Operation
                    )

                    Add-Schema 'boom'
                }
'@
            GivenMigration 'One' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }
                function Pop-Migration
                {
                    Invoke-Ddl 'select 2'
                }
'@
            WhenGettingMigrations
            $script:migrations | Should -Not -BeNullOrEmpty
            $script:migrations.PushOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -HaveCount 2
            $script:migrations.PopOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -HaveCount 2
        }

        It ('should fail') {
            GivenPlugin @'
                function OnAdd
                {
                    [Rivet.Plugin([Rivet.Events]::AfterOperationLoad)]
                    param(
                        $Operation
                    )

                    Add-Schema -Name 'Fubar'
                }
'@
            GivenMigration 'One' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }
                function Pop-Migration
                {
                    Invoke-Ddl 'select 2'
                }
'@
            { WhenGettingMigrations } | Should -Throw '*"AfterOperationLoad" event must have a named "Migration" parameter*'
            $script:migrations | Should -BeNullOrEmpty
        }

        It ('should fail') {
            GivenPlugin @'
                function OnAdd
                {
                    [Rivet.Plugin([Rivet.Events]::AfterOperationLoad)]
                    param(
                        $Migration
                    )

                    Add-Schema -Name 'Fubar'
                }
'@
            GivenMigration 'One' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }
                function Pop-Migration
                {
                    Invoke-Ddl 'select 2'
                }
'@
            { WhenGettingMigrations } | Should -Throw '*"AfterOperationLoad" event must have a named "Operation" parameter*'
            $script:migrations | Should -BeNullOrEmpty
            $Global:Error | Should -Match
        }

        It ('should run the plugin') {
            GivenPlugin @'
                function OnAdd
                {
                    [Rivet.Plugin([Rivet.Events]::AfterOperationLoad)]
                    param(
                        $Migration,
                        $Operation
                    )

                    1
                }
'@
            GivenMigration 'One' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }
                function Pop-Migration
                {
                    Invoke-Ddl 'select 2'
                }
'@
            WhenGettingMigrations
            $script:migrations | Should -Not -BeNullOrEmpty
            $script:migrations.PushOperations | Should -BeOfType ([Rivet.Operations.Operation])
            $script:migrations.PopOperations | Should -BeOfType ([Rivet.Operations.Operation])
        }

        It ('should run the plugin when an AddSchemaOperation exists') {
            GivenPlugin @'
                function OnAdd
                {
                    [Rivet.Plugin([Rivet.Events]::BeforeOperationLoad)]
                    param(
                        $Migration,
                        $Operation
                    )

                    Add-Schema 'boom'
                }

                function AfterMigration
                {

                    [Rivet.Plugin([Rivet.Events]::AfterMigrationLoad)]
                    param(
                        $Migration
                    )

                    $addSchemaOperation = $Migration.PushOperations | Where-Object{ $_ -is [Rivet.Operations.AddSchemaOperation]}

                    if( -not $addSchemaOperation )
                    {
                        Write-Error 'Please add a schema!'
                    }
                }
'@
            GivenMigration 'One' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }
                function Pop-Migration
                {
                    Invoke-Ddl 'select 2'
                }
'@
            WhenGettingMigrations
            $script:migrations | Should -Not -BeNullOrEmpty
            $script:migrations.PushOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -Not -BeNullOrEmpty
            $script:migrations.PushOperations[1] | Should -BeOfType ([Rivet.Operations.RawDdlOperation])
            $script:migrations.PopOperations | Where-Object { $_ -is [Rivet.Operations.AddSchemaOperation] } | Should -Not -BeNullOrEmpty
            $script:migrations.PopOperations[1] | Should -BeOfType ([Rivet.Operations.RawDdlOperation])
        }

        It ('should throw an error when AddSchemaOperation doesn''t exist') {
            GivenPlugin @'
                function AfterMigration
                {

                    [Rivet.Plugin([Rivet.Events]::AfterMigrationLoad)]
                    param(
                        $Migration
                    )

                    $problems = $false
                    $addSchemaOperation = $Migration.PushOperations | Where-Object{ $_ -is [Rivet.Operations.AddSchemaOperation]}

                    if( -not $addSchemaOperation )
                    {
                        throw ('Please add a schema!')
                    }
                }
'@
            GivenMigration 'One' @'
                function Push-Migration
                {
                    Invoke-Ddl 'select 1'
                }
                function Pop-Migration
                {
                    Invoke-Ddl 'select 2'
                }
'@
            { WhenGettingMigrations } | Should -Throw '*Please add a schema!*'
            $script:migrations | Should -BeNullOrEmpty
        }
    }
}