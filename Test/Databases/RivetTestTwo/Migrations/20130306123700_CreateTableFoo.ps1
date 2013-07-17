<#
Your migration is ready to go!  We've set you up with default migrations that just run raw SQL.  Here are some other migrations:

If you have a script for a scripted object, you can use these functions:

    Remove-StoredProcedure -Name <string> [-Schema <string>] [-IfExists]
    Remove-UserDefinedFunction -Name <string> [-Schema <string>] [-IfExists]
    Remove-View -Name <string> [-Schema <string>] [-IfExists]
    Set-StoredProcedure -Name <string> [-Schema <string>]
    Set-UserDefinedFunction -Name <string> [-Schema <string>]
    Set-View -Name <string> [-Schema <string>]
    
To execute raw SQL:

    Invoke-Query -Query <string>

You can use a PowerShell here string for longer queries and so you don't have to escape quotes:

    Invoke-Query -Query @'
       -- SQL goes here    
'@  # '@ must be the first two characters on the line to close the string.
 
To execute a raw SQL script *file*:

    Invoke-SqlScript -Path <string>

To get the path to a script, use the $DBScriptRoot variable, which is set to the current databases scripts root directory:

     = Join-Path  Miscellaneous\CreateMyCustomObject.sql
    Invoke-SqlScript -Path 
    
#>

function Push-Migration()
{
    Invoke-Query -Query 'create table foo( id int not null )'
}

function Pop-Migration()
{
    Invoke-Query -Query 'drop table foo'
}
