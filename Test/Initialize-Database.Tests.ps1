
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

Describe 'Initialize-Database' {
    BeforeEach {
        Start-RivetTest
        Remove-RivetTestDatabase
        @'
    function Push-Migration
    {
        Add-Schema 'initialize'
    }
    
    function Pop-Migration
    {
        Remove-Schema 'initialize'
    }
'@ | New-TestMigration -Name 'First'
    }
    
    AfterEach {
        Stop-RivetTest
    }
    
    It 'should create rivet objects in database' {
        Invoke-RTRivet -Push | Format-Table | Out-String | Write-Verbose
        
        $Global:Error | Should -BeNullOrEmpty
    
        # Migration #1
        (Test-Database) | Should -BeTrue
        (Test-Schema -Name 'rivet') | Should -BeTrue
        (Test-Table -Name 'Migrations' -SchemaName 'rivet') | Should -BeTrue
        (Test-Table -Name 'Activity' -SchemaName 'rivet') | Should -BeTrue
        (Test-StoredProcedure -SchemaName 'rivet' -Name 'InsertMigration') | Should -BeTrue
        (Test-StoredProcedure -SchemaName 'rivet' -Name 'RemoveMigration') | Should -BeTrue
    
        # Migration #2 and #3
        Assert-Column -TableName 'Migrations' -SchemaName 'rivet' -Name 'Name' -DataType 'nvarchar' -Size 241 -NotNull
        Assert-Column -TableName 'Activity' -SchemaName 'rivet' -Name 'Name' -DataType 'nvarchar' -Size 241 -NotNull
        $query = @'
            select sp.name, p.name as parameter_name, p.max_length, t.name as type_name
            from sys.procedures sp
            join sys.parameters p on sp.object_id = p.object_id
            join sys.schemas s on sp.schema_id = s.schema_id
            join sys.types t on p.user_type_id = t.user_type_id
            where s.name = '{0}' and sp.name in ('InsertMigration','RemoveMigration') and p.name in ('@Name','@Who','@ComputerName')
'@ -f $RTRivetSchemaName
    
        Write-Verbose $query
    
        $rows = Invoke-RivetTestQuery -Query $query
        foreach( $row in $rows )
        {
            $row.type_name | Should -Be 'nvarchar'
            if( $row.parameter_name -eq '@Name' )
            {
                # Parameters are nvarchar, so each character is two bytes.
                $row.max_length | Should -Be (241 * 2)
            }
    
        }
    }
    
    It 'should rename pstep schema to rivet' {
        $oldSchemaName = 'pstep'
        $rivetSchemaName = 'rivet'
        Invoke-RTRivet -Push
        $Global:Error | Should -BeNullOrEmpty
        $expectedCount = Measure-Migration
            
        Invoke-RivetTestQuery -Query ('create schema {0}' -f $oldSchemaName)
    
        Invoke-RivetTestQuery -Query ('alter schema {0} transfer {1}.Migrations' -f $oldSchemaName,$RivetSchemaName)
    
        Invoke-RivetTestQuery -Query ('drop table [{0}].[Activity]' -f $RivetSchemaName)
        Invoke-RivetTestQuery -Query ('drop procedure [{0}].[InsertMigration]' -f $RivetSchemaName)
        Invoke-RivetTestQuery -Query ('drop procedure [{0}].[RemoveMigration]' -f $RivetSchemaName)
    
        Invoke-RivetTestQuery -Query ('drop schema {0}' -f $RivetSchemaName)
    
        Invoke-RivetTestQuery -Query 'delete from [pstep].[Migrations] where ID=00000000000001'
    
        (Test-Table -Name 'Migrations' -SchemaName $RivetSchemaName) | Should -BeFalse
        (Test-Table -Name 'Migrations' -SchemaName $oldSchemaName) | Should -BeTrue
        (Test-Schema -Name $RivetSchemaName) | Should -BeFalse
        (Test-Schema -Name $oldSchemaName) | Should -BeTrue
    
        Invoke-RTRivet -Push
        $Global:Error | Should -BeNullOrEmpty
        Measure-Migration | Should -HaveCount $expectedCount
    
        (Test-Table -Name 'Migrations' -SchemaName $RivetSchemaName) | Should -BeTrue
        (Test-Table -Name 'Migrations' -SchemaName $oldSchemaName) | Should -BeFalse
        (Test-Schema -Name $RivetSchemaName) | Should -BeTrue
        (Test-Schema -Name $oldSchemaName) | Should -BeFalse
    }
    
    It 'should change at utc to datetime2' {
        Invoke-RTRivet -Push
        $Global:Error | Should -BeNullOrEmpty
    
        $rivetSchemaName = 'rivet'
        $migrationsTableName = 'Migrations'
    
        $assertColumnParams = @{ 
                                    TableName = $migrationsTableName ; 
                                    SchemaName = $rivetSchemaName ; 
                                    Name = 'AtUtc' ;
                                    NotNull = $true ;
                               }
        Assert-Column -DataType 'datetime2' @assertColumnParams
    
        $query = @'
            alter table {0}.{1} drop constraint DF_rivet_Migrations_AtUtc
            alter table {0}.{1} alter column Atutc datetime not null
            alter table {0}.{1} add constraint AtUtcDefault default (GetUtcDate()) for AtUtc
            delete from [rivet].[Migrations] where ID=00000000000001
'@ -f $rivetSchemaName,$migrationsTableName
        Invoke-RivetTestQuery -Query $query
        Assert-Column -DataType 'datetime' @assertColumnParams
    
        Invoke-RTRivet -Push
        $Global:Error | Should -BeNullOrEmpty
        Assert-Column -DataType 'datetime2' @assertColumnParams
    }
}
