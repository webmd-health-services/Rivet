function Remove-Synonym
{
    <#
    .SYNOPSIS
    Drops a synonym.

    .DESCRIPTION
    Drops an existing synonym.  If the synonym doesn't exist, you'll get an error.
    
    .LINK
    http://technet.microsoft.com/en-us/library/ms174996.aspx
    
    .EXAMPLE
    Remove-Synonym -Name 'Buzz' 
    
    Removes the `Buzz` synonym.
    
    .EXAMPLE
    Remove-Synonym -SchemaName 'fiz' -Name 'Buzz'
    
    Demonstrates how to remove a synonym in a schema other than `dbo`.
    
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=1)]
        [string]
        # The name of the synonym to drop.
        $Name,
        
        [Parameter()]
        [string]
        # The name of the synonym's schema.  Default to `dbo`.
        $SchemaName = 'dbo'
    )

    Write-Verbose(' -{0}.{1}' -f $SchemaName,$Name)
    New-Object 'Rivet.Operations.RemoveSynonymOperation' $SchemaName, $Name
}