
function Invoke-SqlScript
{
    [CmdletBinding(DefaultParameterSetName='AsReader')]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        # The path to the SQL script to execute.
        $Path,

        [Parameter(Mandatory=$true,ParameterSetName='AsScalar')]
        [Switch]
        $AsScalar,
        
        [Parameter(Mandatory=$true,ParameterSetName='AsNonQuery')]
        [Switch]
        $NonQuery,
        
        [UInt32]
        # The time in seconds to wait for the command to execute. The default is 30 seconds.
        $CommandTimeout = 30
    )

    $invokeQueryArgs = @{ }
    if( $pscmdlet.ParameterSetName -eq 'AsScalar' )
    {
        $invokeQueryArgs.AsScalar = $true
    }
    elseif( $pscmdlet.ParameterSetName -eq 'AsNonQuery' )
    {
        $invokeQueryArgs.AsNonQuery = $true
    }
    
    if( -not ([IO.Path]::IsPathRooted( $Path )) )
    {
        $Path = Join-Path $DBMigrationsRoot $Path
    }
    
    $currentQuery = New-Object Text.StringBuilder
    $inComment = $false
    $commentCouldBeStarting = $false
    $commentCouldBeEnding = $false
    $prevChar = $null
    $currentChar = $null
    $commentDepth = 0
    $currentLine = New-Object Text.StringBuilder
    
    Invoke-Command {  Get-Content -Path $Path ; "`nGO`n"  } | # We add `nGO`n to ensure we send the last query to the pipeline. 
        ForEach-Object { $_.ToCharArray() ; "`n" } | # We add `n because Get-Content strips it. 
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

            [void] $currentLine.Append( $currentChar )
            
            if( $currentChar -eq "`n" )
            {
                $trimmedLine = $currentLine.ToString().Trim() 
                if( -not $inComment -and $trimmedLine -match "^GO\b" )
                {
                    if( $currentQuery.Length -gt 0 )
                    {
                        $currentQuery.ToString()
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
        Invoke-Query -CommandTimeout $CommandTimeout @invokeQueryArgs
    
}