
function New-MigrationObject
{
    <#
    .SYNOPSIS
    Creates a new `Rivet.Migration` object, suitable for passing to `Invoke-Migration` function.

    .DESCRIPTION
    All migrations in Rivet should be represented as an object.  Each object should inherit from `Rivet.Migration`.  This method returns an empty `Rivet.Migration` object, which is typically used to create migration-specific properties/methods.

    .EXAMPLE
    $migration = New-MigrationObject

    Returns a `Rivet.Migration` object.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [hashtable]
        # The properties on the object.
        $Property,

        [Parameter(Mandatory=$true)]
        [ScriptBlock]
        # The script block to execute as the ToQuery method.
        $ToQueryMethod
    )

    $o = New-Object 'Rivet.Migration' '','','',''
    $Property.Keys | 
        ForEach-Object { $o | Add-Member -MemberType NoteProperty -Name $_ -Value $Property.$_ }

    $o |
        Add-Member -MemberType ScriptMethod -Name 'ToQuery' -Value $ToQueryMethod -PassThru
}