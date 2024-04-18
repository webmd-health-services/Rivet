
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
    Remove-Item -Path 'alias:GivenMigration'
    Remove-Item -Path 'alias:ThenTable'
    Remove-Item -Path 'alias:ThenDefaultConstraint'

    $script:testDirPath = $null
    $script:testNum = 0
    $script:rivetJsonPath = $null
    $script:dbName = 'Update-Table'

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

    function ThenColumn
    {
        param(
            [String] $Named,

            [String] $OnTable,

            [hashtable] $Is
        )

        Assert-Column -Name $Named -TableName $OnTable -DatabaseName $script:dbName @Is
    }

    function ThenDefaultConstraint
    {
        param(
            [String] $Named,

            [String] $Is
        )

        Assert-DefaultConstraint -Name $Named -Is $Is -DatabaseName $script:dbName
    }

    function ThenTable
    {
        param(
            [Parameter(Mandatory, Position=0)]
            [String] $Named,

            [switch] $Not,

            [Parameter(Mandatory)]
            [switch] $Exists
        )

        $exists = Test-Table -Name $Named -DatabaseName $script:dbName

        if ($Not)
        {
            $exists | Should -BeFalse
        }
        else
        {
            $exists | Should -BeTrue
        }
    }

    function WhenPushing
    {
        Invoke-Rivet -Push -ConfigFilePath $script:rivetJsonPath
    }
}

Describe 'Update-Table' {
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

    It 'should update column from int to bigint with description' {
        GivenMigration 'UpdateDateColumnWithDescription' @'
            function Push-Migration
            {
                Add-Table -Name 'Foobar' -Column {
                    Int 'id' -Description 'Foo'
                } -Option 'data_compression = none'

                Update-Table -Name 'Foobar' -UpdateColumn {
                    BigInt 'id' -Description 'Bar'
                }
            }

            function Pop-Migration
            {
                Remove-Table 'Foobar'
            }
'@

        WhenPushing
        ThenTable 'Foobar' -Exists
        ThenColumn 'id' -OnTable 'Foobar' -Is @{ DataType = 'BigInt' ; Description = 'Bar' }
    }

    It 'should update column from binary to varbinary' {
        GivenMigration 'ShouldUpdateColumnFromBinarytoVarBinary' @'
            function Push-Migration
            {
                Add-Table -Name 'Foobar' -Column {
                    Binary 'id' -NotNull -Size 50
                }

                Update-Table -Name 'Foobar' -UpdateColumn {
                    VarBinary 'id' -Size 40 -Sparse
                }
            }

            function Pop-Migration
            {
                Remove-Table 'Foobar'
            }
'@

        WhenPushing
        ThenTable 'Foobar' -Exist
        ThenColumn 'id' -OnTable 'Foobar' -Is @{ DataType = 'VarBinary' ; Sparse = $true ; Size = 40 }
    }

    It 'should update column from nchar to nvarchar' {
        GivenMigration 'ShouldUpdateColumnFromNChartoNVarChar' @'
            function Push-Migration
            {
                Add-Table -Name 'Foobar' -Column {
                    NChar 'id' 30
                }

                Update-Table -Name 'Foobar' -UpdateColumn {
                    NVarChar 'id' -Max -Collation "Chinese_Taiwan_Stroke_CI_AS" -NotNull
                }
            }

            function Pop-Migration
            {
                Remove-Table 'Foobar'
            }
'@

        WhenPushing

        ThenTable 'Foobar' -Exists
        ThenColumn 'id' -OnTable 'Foobar' -Is @{
            DataType = 'NVarChar'
            NotNull = $true;
            Max = $true;
            Collation = "Chinese_Taiwan_Stroke_CI_AS";
        }
    }

    It 'should update column from nvarchar to xml' {
        GivenMigration 'ShouldUpdateColumnFromNVarChartoXml'@"
            function Push-Migration
            {
                    Invoke-Ddl -Query @'
                        create xml schema collection EmptyXsd as
                        N'
                        <xsd:schema targetNamespace="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions"
                        xmlns          ="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/ProductModelManuInstructions"
                        elementFormDefault="qualified"
                        attributeFormDefault="unqualified"
                        xmlns:xsd="http://www.w3.org/2001/XMLSchema" >

                            <xsd:element  name="root" />

                        </xsd:schema>
                        ';
'@

                Add-Table -Name 'WithXmlContent' -Column {
                    VarChar 'One' -Max -NotNull
                    Xml 'Two' -XmlSchemaCollection 'EmptyXsd'
                }

                Update-Table -Name 'WithXmlContent' -UpdateColumn{
                    Xml 'Two' -XmlSchemaCollection 'EmptyXsd'
                }
            }

            function Pop-Migration
            {
                Remove-Table 'WithXmlContent'
                Invoke-Ddl 'drop xml schema collection EmptyXsd'
            }
"@

        WhenPushing

        ThenTable 'WithXmlContent' -Exists
        ThenColumn -Name 'Two' -OnTable 'WithXmlContent' -Is @{ DataType = 'Xml' }
    }

    It 'should update column after add column in update table' {
        GivenMigration 'UpdateDateColumnWithDescription' @'
            function Push-Migration
            {
                Add-Table -Name 'Foobar' -Column {
                    Int 'id' -Description 'Foo'
                }

                Update-Table -Name 'Foobar' -AddColumn {
                    VarChar 'id2' -Max -Description 'Foo2'
                }

                Update-Table -Name 'FooBar' -UpdateColumn {
                    BigInt 'id2' -Description 'Bar'
                }

                Update-Table -Name 'Foobar' -UpdateColumn {
                    VarChar 'id' -Max -Description 'Bar2'
                } -AddColumn {
                    BigInt 'id3' -Description 'Foo'
                }
            }

            function Pop-Migration
            {
                Remove-Table 'Foobar'
            }
'@

        WhenPushing

        ThenTable 'Foobar' -Exists
        ThenColumn 'id' -OnTable 'Foobar' -Is @{ DataType = 'VarChar' ; Max = $true ; Description = 'Bar2' }
        ThenColumn 'id2' -OnTable 'Foobar' -Is @{ DataType = 'BigInt' ; Description = 'Bar' }
        ThenColumn 'id3' -OnTable 'Foobar' -Is @{ DataType = 'BigInt' ; Description = 'Foo' }
    }

    It 'should use custom constraint name' {
        GivenMigration -Named 'CustomConstraintNames' @'
            function Push-Migration
            {
                Add-Table 'CustomConstraintNames' {
                    int 'ID'
                }

                Update-Table 'CustomConstraintNames' -AddColumn {
                    int 'column2' -NotNull -Default 2 -DefaultConstraintName 'DF_Two'
                    int 'column3' -Identity
                }
            }

            function Pop-Migration
            {
                Remove-Table 'CustomConstraintNames'
            }
'@
        WhenPushing
        ThenDefaultConstraint 'DF_Two' -Is 'snafu'
    }

    It 'does not add default constraint to an existing column' {
        GivenMigration 'DefaultConstraintOnExistingColumn' @'
            function Push-Migration
            {
                Add-Table 'DefaultConstraintOnExistingColumn' {
                    int 'column1'
                }

                Update-Table 'DefaultConstraintOnExistingColumn' -UpdateColumn {
                    int 'column1' -NotNull -Default 2 -DefaultConstraintName 'DF_Two'
                }
            }

            function Pop-Migration
            {
                Remove-Table 'DefaultConstraintOnExistingColumn'
            }
'@
        { WhenPushing } | Should -Throw
        ThenError -Matches 'Use the Add-DefaultConstraint operation'
        ThenTable 'DefaultConstraintOnExistingColumn' -Not -Exists
    }

    It 'rejects adding an idenity to an existng column' {
        GivenMigration -Named 'IdentityOnExistingColumn' @'
            function Push-Migration
            {
                Add-Table 'IdentityOnExistingColumn' {
                    int 'column1'
                }

                Update-Table 'IdentityOnExistingColumn' -UpdateColumn {
                    int 'column1' -Identity
                }
            }

            function Pop-Migration
            {
                Remove-Table 'IdentityOnExistingColumn'
            }
'@
        { WhenPushing } | Should -Throw
        ThenError -Matches 'identity'
        ThenTable 'IdentityOnExistingColumn' -Not -Exists
    }
}