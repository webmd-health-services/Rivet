
function Stop-Migration
{
    <#
    .SYNOPSIS
    Stops a migration from getting poppped.

    .DESCRIPTION
    The `Stop-Migration` operation stops a migration from getting popped. When put in your migration's `Pop-Migration` function, the migration will fail when someone attempts to pop it. Use this operation to mark a migration as irreversible.

    `Stop-Migration` was added in Rivet 0.6.

    .EXAMPLE
    Stop-Migration

    Demonstrates how to use use `Stop-Migration`.

    .EXAMPLE
    Stop-Migration -Message 'The datatabase's flibbers have been upgraed to flobbers. This operation can't be undone. Sorry.'

    Demonstrates how to display a message explaining why the migration isn't reversible.
    #>
    [CmdletBinding()]
    param(
        [string]
        # A message to show that explains why the migrations isn't reversible. Default message is `This migration is irreversible and can't be popped.`.
        $Message = 'This migration is irreversible and can''t be popped.'
    )

    Set-StrictMode -Version 'Latest'

    New-Object -TypeName 'Rivet.Operations.IrreversibleOperation' -ArgumentList $Message
}