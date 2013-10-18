function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddDataType' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldAddDataTypeByAlias
{
    @'
function Push-Migration
{
    Add-DataType 'GUID' 'uniqueidentifier'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'ByAlias'

    Invoke-Rivet -Push 'ByAlias'
    
    Invoke-RivetTestQuery -Query 'create table important (ident GUID);'
    Assert-Table 'important'
    Assert-Column 'ident' -DataType 'GUID' -TableName 'important'
}

function Ignore-ShouldAddDataTypeByAssembly
{
    @'
function Push-Migration
{
    Invoke-Query "create assembly rivettest from 'D:\build\Rivet\Source\Rivet.Test.Fake\bin\Debug\Rivet.Test.Fake.dll' "
    Add-DataType 'Point' -AssemblyName 'rivettest' -ClassName 'Rivet.Test.Fake.Point'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'ByAssembly'

    Invoke-Rivet -Push 'ByAssembly'
    
    Invoke-RivetTestQuery -Query 'create table important (ident Point);'
    Assert-Table 'important'
    Assert-Column 'ident' -DataType 'Point' -TableName 'important'
}

function Test-ShouldAddDataTypeByTable
{
    @'
function Push-Migration
{
    Add-DataType 'Users' -AsTable { varchar 'Name' 50 } -TableConstraint 'primary key'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'ByTable'

    Invoke-Rivet -Push 'ByTable'

    $temp = Invoke-RivetTestQuery -Query 'select * from sys.table_types'
    Assert-Equal "Users" $temp[0].name
}