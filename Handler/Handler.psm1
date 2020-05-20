#region Copyright & License

# Copyright © 2012 - 2020 François Chabot
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.u
# See the License for the specific language governing permissions and
# limitations under the License.

#endregion

Set-StrictMode -Version Latest

enum Direction {
    Receive
    Send
}

<#
.SYNOPSIS
    Gets information Microsoft BizTalk Server adapter's handlers.
.DESCRIPTION
    Gets information Microsoft BizTalk Server adapter's handlers.
.PARAMETER Adapter
    The name of the Microsoft BizTalk Server adapter to get.
.PARAMETER Host
    The name of the Microsoft BizTalk Server host for which to get the adapter's handlers.
.PARAMETER Direction
    The direction of the Microsoft BizTalk Server adapter's handlers to get.
.OUTPUTS
    Returns information about Microsoft BizTalk Server adapter's handlers.
.EXAMPLE
    PS> Get-BizTalkHandler -Adapter FILE
.EXAMPLE
    PS> Get-BizTalkHandler -Host BiztAlkServerIsolatedHost
.EXAMPLE
    PS> Get-BizTalkHandler -Direction Send
.EXAMPLE
    PS> Get-BizTalkHandler -Adapter FILE -Host BizTalkServerApplication -Direction Send
.NOTES
    © 2020 be.stateless.
#>
function Get-BizTalkHandler {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string[]]
        $Adapter = @([string]::Empty),

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string[]]
        $Host = @([string]::Empty),

        [Parameter(Mandatory = $false)]
        [Direction[]]
        $Direction = @([Direction]::Receive, [Direction]::Send)
    )

    foreach ($d in $Direction) {
        $className = Get-HandlerCimClassName -Direction $d
        foreach ($a in $Adapter) {
            foreach ($h in $Host) {
                $filter = if (![string]::IsNullOrWhiteSpace($a) -and ![string]::IsNullOrWhiteSpace($h)) {
                    "AdapterName='$a' and HostName='$h'"
                } elseif (![string]::IsNullOrWhiteSpace($a)) {
                    "AdapterName='$a'"
                } elseif (![string]::IsNullOrWhiteSpace($h)) {
                    "HostName='$h'"
                }
                Get-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName $className -Filter $filter |
                    Add-Member -NotePropertyName Direction -NotePropertyValue $d -PassThru
            }
        }
    }
}

<#
.SYNOPSIS
    Creates a Microsoft BizTalk Server adapter's handler.
.DESCRIPTION
    Creates and configures a Microsoft BizTalk Server adapter's handler.
.PARAMETER Adapter
    The name of the adapter for which to create a Microsoft BizTalk Server handler.
.PARAMETER Host
    The name of the host that will run the Microsoft BizTalk Server handler.
.PARAMETER Direction
    The diretion of the Microsoft BizTalk Server handler to be created, either Receive or Send.
.PARAMETER Default
    Whether the Microsoft BizTalk Server handler to be created will be the default adapter's handler.
.EXAMPLE
    PS> New-BizTalkHandler -Adapter FILE -Host BizTalkServerApplication -Direction Receive
.LINK
    https://docs.microsoft.com/en-us/biztalk/core/technical-reference/creating-an-ftp-receive-handler-using-wmi
.NOTES
    © 2020 be.stateless.
#>
function New-BizTalkHandler {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Adapter,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Host,

        [Parameter(Mandatory = $true)]
        [Direction]
        $Direction,

        # TODO refactor $Default as a Dynamic param which is only availble when $Direction = Send
        [Parameter(Mandatory = $false)]
        [switch]
        $Default
    )
    if (Test-BizTalkHandler -Adapter $Adapter -Host $Host -Direction $Direction) {
        Write-Information "`t $Direction $Adapter handler for '$Host' host already exists."
    } elseif ($PsCmdlet.ShouldProcess("BizTalk Group", "Creating $Direction $Adapter handler for '$Host' host")) {
        Write-Verbose "`t Creating $Direction $Adapter handler for '$Host' host..."
        $className = Get-HandlerCimClassName -Direction $Direction
        $properties = @{ AdapterName = $Adapter ; HostName = $Host }
        if ($Direction -eq 'Send' -and $Default.IsPresent) { $properties.IsDefault = [bool]$Default }
        New-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName $className -Property $properties | Out-Null
        Write-Information "`t $Direction $Adapter handler for '$Host' host has been created."
    }
}

<#
.SYNOPSIS
    Removes a Microsoft BizTalk Server handler.
.DESCRIPTION
    Removes a Microsoft BizTalk Server handler.
.PARAMETER Adapter
    The name of the adapter for which a Microsoft BizTalk Server handler has to be removed.
.PARAMETER Host
    The name of the host that runs the Microsoft BizTalk Server handler to be removed.
.PARAMETER Direction
    The diretion of the Microsoft BizTalk Server handler to be removed, either Receive or Send.
.EXAMPLE
    PS> Remove-BizTalkHandler -Adapter FILE -Host BizTalkServerApplication -Direction Receive
.NOTES
    © 2020 be.stateless.
#>
function Remove-BizTalkHandler {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Adapter,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Host,

        [Parameter(Mandatory = $true)]
        [Direction]
        $Direction
    )
    if (-not (Test-BizTalkHandler -Adapter $Adapter -Host $Host -Direction $Direction)) {
        Write-Information "`t $Direction $Adapter handler for '$Host' host does not exist."
    } elseif ($PsCmdlet.ShouldProcess("BizTalk Group", "Removing $Direction $Adapter handler for '$Host' host")) {
        Write-Verbose "`t Removing $Direction $Adapter handler for '$Host' host..."
        $className = Get-HandlerCimClassName -Direction $Direction
        # TODO fail if try to remove default send handler
        $instance = Get-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName $className -Filter "AdapterName='$Adapter' and HostName='$Host'"
        Remove-CimInstance -InputObject $instance
        Write-Information "`t $Direction $Adapter handler for '$Host' host has been deleted."
    }
}

<#
.SYNOPSIS
    Returns whether a Microsoft BizTalk Server adapter's handler exists.
.DESCRIPTION
    This command will return $true if the Microsoft BizTalk Server adapter's handler exists; $false otherwise.
.PARAMETER Adapter
    The name of the adapter for which the existence of a Microsoft BizTalk Server handler is tested.
.PARAMETER Host
    The name of the host that runs the Microsoft BizTalk Server handler whose existence is tested.
.PARAMETER Direction
    The diretion of the Microsoft BizTalk Server handler whose existence is to be tested, either Receive or Send.
.OUTPUTS
    $true if the BizTalk Server handler exists; $false otherwise.
.EXAMPLE
    PS> Test-BizTalkHandler -Adapter FILE -Host BizTalkServerApplication -Direction Send
.NOTES
    © 2020 be.stateless.
#>
function Test-BizTalkHandler {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Adapter,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Host,

        [Parameter(Mandatory = $true)]
        [Direction]
        $Direction
    )
    $className = Get-HandlerCimClassName -Direction $Direction
    [bool] (Get-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName $className -Filter "AdapterName='$Adapter' and HostName='$Host'")
}

function Get-HandlerCimClassName {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [Direction]
        $Direction
    )
    if ($direction -eq [Direction]::Receive) { 'MSBTS_ReceiveHandler' } else { 'MSBTS_SendHandler2' }
}