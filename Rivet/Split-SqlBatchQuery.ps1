
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
        $inSingleLineComment = $false
        $inMultiLineComment = $false
        $inString = $false
        $justClosedString = $false
        $stringCouldBeEnding = $false
        $prevChar = $null
        $currentChar = $null
        $commentDepth = 0
        $currentLine = New-Object 'Text.StringBuilder'

        $chars = Invoke-Command { 
                                    $Query.ToCharArray()
                                    "`nGO`n".ToCharArray() # We add `nGO`n to ensure we send the last query to the pipeline. 
                                }
        for( $idx = 0; $idx -lt $chars.Count; ++$idx )
        {
            $justClosedString = $false

            $prevChar = $null
            if( $idx -gt 1 )
            {
                $prevChar = $chars[$idx - 1]
            }

            $currentChar = $chars[$idx]

            $nextChar = $null
            if( $idx + 1 -lt $chars.Count )
            {
                $nextChar = $chars[$idx + 1]
            }

            if( $inMultiLineComment )
            {
                [void] $currentLine.Append( $currentChar )
                if( $prevChar -eq '/' -and $currentChar -eq '*' )
                {
                    Write-Verbose ('Entering nested multi-line comment.')
                    $commentDepth++
                    continue
                }
                elseif( $prevChar -eq '*' -and $currentChar -eq '/' )
                {
                    Write-Verbose ('Leaving multi-line comment.')
                    $commentDepth--
                    $inMultiLineComment = ($commentDepth -gt 0)
                }

                if( -not $inMultiLineComment )
                {
                    Write-Verbose ('Multi-line comment closed.')
                }
                continue
            }

            if( $inSingleLineComment )
            {
                if( $currentChar -eq "`n" )
                {
                    Write-Verbose ('Leaving single-line comment.')
                    $inSingleLineComment = $false
                }
                else
                {
                    [void] $currentLine.Append( $currentChar )
                    continue
                }
            }
            
            if( $inString )
            {
                [void] $currentLine.Append( $currentChar )
                if( $prevChar -ne "'" -and $currentChar -eq "'" -and $nextChar -ne "'" )
                {
                    Write-Verbose ('Leaving string.')
                    $inString = $false
                }
                continue
            }

            if( $prevChar -eq "/" -and $currentChar -eq "*" )
            {
                Write-Verbose ('Entering multi-line comment.')
                $inMultiLineComment = $true
                $commentDepth++
            }
            elseif( $prevChar -eq '-' -and $currentChar -eq '-' )
            {
                Write-Verbose ('Entering single-line comment.')
                $inSingleLineComment = $true
            }
            elseif( $currentChar -eq "'" -and $nextChar -ne "'" -and $prevChar -ne "'" )
            {
                Write-Verbose ('Entering string.')
                $inString = $true
            }

            [void] $currentLine.Append( $currentChar )

            if( $currentChar -eq "`n" )
            {
                $inSingleLineComment = $false

                Write-Verbose ("inMultiLineComment: {0}; inSingleLineComment: {1}; inString {2}; {3}" -f $inMultiLineComment,$inSingleLineComment,$inString,$currentLine.ToString())
                $trimmedLine = $currentLine.ToString().Trim() 
                if( -not $inMultiLineComment -and -not $inString -and $trimmedLine -match "^GO\b" )
                {
                    if( $currentQuery.Length -gt 0 )
                    {
                        $splitQuery = $currentQuery.ToString().Trim()
                        if( $splitQuery )
                        {
                            Write-Debug $splitQuery
                            $splitQuery
                        }
                        $currentQuery.Length = 0
                    }
                }
                else
                {
                    $null = $currentQuery.Append( $currentLine )
                }
                $currentLine.Length = 0
            }
        }
    }
    end
    {
    }
}