
function Invoke-Ddl
{
    <#
    .SYNOPSIS
    Executes a DDL statement against the database.
    
    .DESCRIPTION
    The `Invoke-Ddl` function is used to update the structure of a database when none of Rivet's other operations will work.
    
    .EXAMPLE
    Invoke-Ddl -Query 'create table rivet.Migrations ( id int not null )'
    
    Executes the create table syntax above against the database.
    #>
    [CmdletBinding(DefaultParameterSetName='AsReader')]
    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [string]
        $Query
    )

    Set-StrictMode -Version 'Latest'

    $Query |
        Split-SqlBatchQuery |
        Where-Object { $_ } |
        ForEach-Object {
            Write-Verbose $_
            New-Object 'Rivet.Operations.RawQueryOperation' $_
        }

}
