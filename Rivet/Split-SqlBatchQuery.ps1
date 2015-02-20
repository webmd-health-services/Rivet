
function Split-SqlBatchQuery
{
    <#
    .SYNOPSIS
    Splits a SQL batch query into individual queries.

    .DESCRIPTION
    `Split-SqlBatchQuery` takes a batch query and splits it by the `GO` statements it contains. `GO` statements inside comments and strings are ignored. It does not use regular expressions.

    If the query has no `GO` statements, you'll get your original query back.

    You can pipe SQL batch queries into this function and you'll get runnable queries out the other side.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [string]
        $Query
    )

    begin
    {
    }

    process
    {
        Set-StrictMode -Version 'Latest'

        $currentQuery = New-Object 'Text.StringBuilder'
        $inComment = $false
        $commentCouldBeStarting = $false
        $commentCouldBeEnding = $false
        $prevChar = $null
        $currentChar = $null
        $commentDepth = 0
        $currentLine = New-Object 'Text.StringBuilder'

        Invoke-Command { 
                $Query.ToCharArray()
                "`nGO`n".ToCharArray() # We add `nGO`n to ensure we send the last query to the pipeline. 
            } | 
            ForEach-Object {
                $prevChar = $currentChar
                $currentChar = $_
            
                if( $inComment -and $prevChar -eq '*' -and $currentChar -eq '/' )
                {
                    $commentDepth--
                    $inComment = ($commentDepth -gt 0)
                }

                if( $prevChar -eq '/' -and $currentChar -eq '*' )
                {
                    $inComment = $true
                    $commentDepth++
                }

                if( $currentChar -eq "`r" )
                {
                    return
                }
            
                [void] $currentLine.Append( $currentChar )

                if( $currentChar -eq "`n" )
                {
                    $trimmedLine = $currentLine.ToString().Trim() 
                    if( -not $inComment -and $trimmedLine -match "^GO\b" )
                    {
                        if( $currentQuery.Length -gt 0 )
                        {
                            $currentQuery.ToString().Trim()
                            $currentQuery.Length = 0
                        }
                    }
                    else
                    {
                        $null = $currentQuery.Append( $currentLine )
                    }
                    $currentLine.Length = 0
                }
            
            } |
            Where-Object { $_.Trim() }
    }
    end
    {
    }
}