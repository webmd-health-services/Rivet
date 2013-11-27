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
    # Yes.  Spaces in the name so we check the name gets quoted.
    @'
function Push-Migration
{
    Add-DataType 'G U I D' 'uniqueidentifier'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'ByAlias'

    Invoke-Rivet -Push 'ByAlias'
    
    Invoke-RivetTestQuery -Query 'create table important (ident [G U I D]);'
    Assert-Table 'important'
    Assert-Column 'ident' -DataType 'G U I D' -TableName 'important'
}

function Test-ShouldAddDataTypeByAssembly
{
    $assemblyPath = Join-Path -Path $PSScriptRoot -ChildPath '..\Source\Rivet.Test.Fake\bin\Debug\Rivet.Test.Fake.dll' -Resolve
    # Yes.  Spaces in the name so we check the name gets quoted.
    @"
function Push-Migration
{
    Invoke-Query "create assembly rivettest from '$assemblyPath' "
    Add-DataType 'Point Point' -AssemblyName 'rivettest' -ClassName 'Rivet.Test.Fake.Point'
}

function Pop-Migration
{
    
}

"@ | New-Migration -Name 'ByAssembly'

    Invoke-Rivet -Push 'ByAssembly'
    
    Invoke-RivetTestQuery -Query 'create table important (ident [Point Point]);'
    Assert-Table 'important'
    Assert-Column 'ident' -DataType 'Point Point' -TableName 'important'
}

function Test-ShouldAddDataTypeByTable
{
    # Yes.  Spaces in the name so we check the name gets quoted.
    @'
function Push-Migration
{
    Add-DataType 'U s e r s' -AsTable { varchar 'Name' 50 } -TableConstraint 'primary key'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'ByTable'

    Invoke-Rivet -Push 'ByTable'

    $temp = Invoke-RivetTestQuery -Query 'select * from sys.table_types'
    Assert-Equal "U s e r s" $temp[0].name
}