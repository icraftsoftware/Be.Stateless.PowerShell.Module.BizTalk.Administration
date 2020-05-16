#region Copyright & License

# Copyright © 2012 - 2022 François Chabot
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
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
   Asserts the existence of a Microsoft BizTalk Server Adapter Handler.
.DESCRIPTION
   This command will throw if the Microsoft BizTalk Server Adapter Handler does not exist and will silently complete
   otherwise.
.PARAMETER Adapter
   The adapter name of the Microsoft BizTalk Server Adapter Handler.
.PARAMETER Host
   The host name of the Microsoft BizTalk Server Host Handler.
.PARAMETER Direction
   The direction of the Microsoft BizTalk Server Adapter Handler.
.EXAMPLE
   PS> Assert-BizTalkHandler -Adapter FILE -Host BizTalkServerApplication -Direction Send
.NOTES
   © 2022 be.stateless.
#>
function Assert-BizTalkHandler {
   [CmdletBinding()]
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
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
   if (-not(Test-BizTalkHandler @PSBoundParameters)) {
      throw "Microsoft BizTalk Server $Direction '$Adapter' handler for '$Host' host does not exist."
   }
   Write-Verbose -Message "Microsoft BizTalk Server $Direction '$Adapter' handler for '$Host' host exists."
}

<#
.SYNOPSIS
   Gets information Microsoft BizTalk Server Adapter Handlers.
.DESCRIPTION
   Gets information Microsoft BizTalk Server Adapter Handlers.
.PARAMETER Adapter
   The adapter name of the Microsoft BizTalk Server Adapter Handlers.
.PARAMETER Host
   The host name of the Microsoft BizTalk Server Host Handlers.
.PARAMETER Direction
   The direction of the Microsoft BizTalk Server Adapter Handlers.
.OUTPUTS
   Returns information about Microsoft BizTalk Server Adapter Handlers.
.EXAMPLE
   PS> Get-BizTalkHandler -Adapter FILE
.EXAMPLE
   PS> Get-BizTalkHandler -Host BiztAlkServerIsolatedHost
.EXAMPLE
   PS> Get-BizTalkHandler -Direction Send
.EXAMPLE
   PS> Get-BizTalkHandler -Adapter FILE -Host BizTalkServerApplication -Direction Send
.NOTES
   © 2022 be.stateless.
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
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
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
            Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName $className -Filter $filter |
               Add-Member -NotePropertyName Direction -NotePropertyValue $d -PassThru
         }
      }
   }
}

<#
.SYNOPSIS
   Creates a Microsoft BizTalk Server Adapter Handler.
.DESCRIPTION
   Creates a Microsoft BizTalk Server Adapter Handler.
.PARAMETER Adapter
   The adapter name of the Microsoft BizTalk Server Adapter Handler.
.PARAMETER Host
   The host name of the Microsoft BizTalk Server Host Handler.
.PARAMETER Direction
   The direction of the Microsoft BizTalk Server Adapter Handler.
.PARAMETER Default
   Whether the Microsoft BizTalk Server Adapter Handler to be created will be the default Adapter Handler.
.EXAMPLE
   PS> New-BizTalkHandler -Adapter FILE -Host BizTalkServerApplication -Direction Receive
.LINK
   https://docs.microsoft.com/en-us/biztalk/core/technical-reference/creating-an-ftp-receive-handler-using-wmi
.NOTES
   © 2022 be.stateless.
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
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
   if (Test-BizTalkHandler -Adapter $Adapter -Host $Host -Direction $Direction) {
      Write-Information -MessageData "`t Microsoft BizTalk Server $Direction '$Adapter' handler for '$Host' host has already been created."
   } elseif ($PsCmdlet.ShouldProcess($globalMessages.Should_Target, "Creating $Direction '$Adapter' handler for '$Host' host")) {
      Write-Information -MessageData "`t Creating Microsoft BizTalk Server $Direction '$Adapter' handler for '$Host' host..."
      $className = Get-HandlerCimClassName -Direction $Direction
      $properties = @{ AdapterName = $Adapter ; HostName = $Host }
      if ($Direction -eq 'Send' -and $Default.IsPresent) { $properties.IsDefault = [bool]$Default }
      New-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName $className -Property $properties | Out-Null
      Write-Information -MessageData "`t Microsoft BizTalk Server $Direction '$Adapter' handler for '$Host' host has been created."
   }
}

<#
.SYNOPSIS
   Removes a Microsoft BizTalk Server Adapter Handler.
.DESCRIPTION
   Removes a Microsoft BizTalk Server Adapter Handler.
.PARAMETER Adapter
   The adapter name of the Microsoft BizTalk Server Adapter Handler.
.PARAMETER Host
   The host name of the Microsoft BizTalk Server Host Handler.
.PARAMETER Direction
   The direction of the Microsoft BizTalk Server Adapter Handler.
.EXAMPLE
   PS> Remove-BizTalkHandler -Adapter FILE -Host BizTalkServerApplication -Direction Receive
.NOTES
   © 2022 be.stateless.
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
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
   if (-not(Test-BizTalkHandler -Adapter $Adapter -Host $Host -Direction $Direction)) {
      Write-Information -MessageData "`t Microsoft BizTalk Server $Direction '$Adapter' handler for '$Host' host has already been removed."
   } elseif ($PsCmdlet.ShouldProcess($globalMessages.Should_Target, "Removing $Direction '$Adapter' handler for '$Host' host")) {
      Write-Information -MessageData "`t Removing Microsoft BizTalk Server $Direction '$Adapter' handler for '$Host' host..."
      $className = Get-HandlerCimClassName -Direction $Direction
      # TODO will fail if try to remove default send handler
      $instance = Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName $className -Filter "AdapterName='$Adapter' and HostName='$Host'"
      Remove-CimInstance -ErrorAction Stop -InputObject $instance
      Write-Information -MessageData "`t Microsoft BizTalk Server $Direction '$Adapter' handler for '$Host' host has been removed."
   }
}

<#
.SYNOPSIS
   Returns whether a Microsoft BizTalk Server Adapter Handler exists.
.DESCRIPTION
   This command will return $true if the Microsoft BizTalk Server Adapter Handler exists; $false otherwise.
.PARAMETER Adapter
   The adapter name of the Microsoft BizTalk Server Adapter Handler.
.PARAMETER Host
   The host name of the Microsoft BizTalk Server Host Handler.
.PARAMETER Direction
   The direction of the Microsoft BizTalk Server Adapter Handler.
.OUTPUTS
   $true if the Microsoft BizTalk Server handler exists; $false otherwise.
.EXAMPLE
   PS> Test-BizTalkHandler -Adapter FILE -Host BizTalkServerApplication -Direction Send
.NOTES
   © 2022 be.stateless.
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
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
   $className = Get-HandlerCimClassName -Direction $Direction
   [bool] (Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName $className -Filter "AdapterName='$Adapter' and HostName='$Host'")
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