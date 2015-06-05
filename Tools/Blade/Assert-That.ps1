# Copyright 2012 - 2015 Aaron Jensen
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function Assert-That
{
    <#
    .SYNOPSIS
    Asserts that an object meets certain conditions and throws an exception when they aren't.

    .DESCRIPTION
    The `Assert-That` function checks that a given set of condiions are true and if they aren't, it throws a `Blade.AssertionException`.

    .EXAMPLE
    Assert-That { throw 'Fubar!' } -Throws [Management.Automation.RuntimeException]

    Demonstrates how to check that a script block throws an exception.
    
    .EXAMPLE
    Assert-That { } -DoesNotThrowException
    
    Demonstrates how to check that a script block doesn't throw an exception.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [object]
        # The object whose conditions you're checking.
        $InputObject,

        [Parameter(Mandatory=$true,ParameterSetName='ThrowsException')]
        [Type]
        # The type of the exception `$InputObject` should throw. When this parameter is provided, $INputObject should be a script block.
        $Throws,

        [Parameter(ParameterSetName='ThrowsException')]
        [string]
        # Used with the `Throws` switch. Checks that the thrown exception message matches a regular rexpression.
        $AndMessageMatches,

        [Parameter(Mandatory=$true,ParameterSetName='DoesNotThrowException')]
        [Switch]
        # Asserts that the script block given by `InputObject` does not throw an exception.
        $DoesNotThrowException,

        [Parameter(ParameterSetName='ThrowsException',Position=1)]
        [string]
        # The message to show when the assertion fails.
        $Message
    )

    Set-StrictMode -Version 'Latest'

    switch( $PSCmdlet.ParameterSetName )
    {

        'DoesNotThrowException'
        {
            if( $InputObject -isnot [scriptblock] )
            {
                throw 'When using `DoesNotThrowException` parameter, `-InputObject` must be a ScriptBlock.'
            }

            try
            {
                Invoke-Command -ScriptBlock $InputObject
            }
            catch
            {
                Fail ('Script block threw an exception: {0}  {1}' -f $_.Exception,$Message)
            }
        }

        'ThrowsException'
        {
            if( $InputObject -isnot [scriptblock] )
            {
                throw 'When using `Throws` parameter, `-InputObject` must be a ScriptBlock.'
            }

            $threwException = $false
            $ex = $null
            try
            {
                Invoke-Command -ScriptBlock $InputObject
            }
            catch
            {
                $ex = $_.Exception
                if( $ex -is $Throws )
                {
                    $threwException = $true
                }
                else
                {
                    Fail ('Expected ScriptBlock to throw a {0} exception, but it threw: {1}  {2}' -f $Throws,$ex,$Message)
                }
            }

            if( -not $threwException )
            {
                Fail ('ScriptBlock did not throw a ''{0}'' exception. {1}' -f $Throws.FullName,$Message)
            }

            if( $AndMessageMatches )
            {
                if( $ex.Message -notmatch $AndMessageMatches )
                {
                    Fail ('Exception message ''{0}'' doesn''t match ''{1}''.' -f $ex.Message,$AndMessageMatches)
                }
            }
        }
    }
}