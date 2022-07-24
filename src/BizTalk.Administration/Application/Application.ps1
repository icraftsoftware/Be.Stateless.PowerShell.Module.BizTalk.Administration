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

using namespace Microsoft.BizTalk.ExplorerOM
using namespace Microsoft.BizTalk.Operations

Set-StrictMode -Version Latest

<#
.SYNOPSIS
   Asserts the existence of a Microsoft BizTalk Server Application.
.DESCRIPTION
   This command will throw if the Microsoft BizTalk Server Application does not exist and will silently complete
   otherwise.
.PARAMETER Name
   The name of the Microsoft BizTalk Server Application.
.PARAMETER Reference
   The name of the Microsoft BizTalk Server Applications that are to be referenced by the one whose existence is
   tested.
.PARAMETER ManagementDatabaseServer
   The name of the SQL server hosting the management database; it defaults to MSBTS_GroupSetting.MgmtDbServerName.
.PARAMETER ManagementDatabaseName
   The name of the management database; it defaults to MSBTS_GroupSetting.MgmtDbName.
.EXAMPLE
   PS> Assert-BizTalkApplication
.EXAMPLE
   PS> Assert-BizTalkApplication -Name 'BizTalk.System'
.NOTES
   © 2022 be.stateless.
#>
function Assert-BizTalkApplication {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $Name,

      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Reference,

      [Parameter(Position = 1, Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $ManagementDatabaseServer = (Get-BizTalkGroupMgmtDbServer),

      [Parameter(Position = 2, Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $ManagementDatabaseName = (Get-BizTalkGroupMgmtDbName)
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
   if (-not(Test-BizTalkApplication @PSBoundParameters)) {
      if ($Reference | Test-None) {
         throw "Microsoft BizTalk Server Application '$Name' does not exist."
      } else {
         throw "Microsoft BizTalk Server Application '$Name' does not exist or some the required application references '$($Reference -join ''', ''')' are missing."
      }
   }
   Write-Verbose -Message "Microsoft BizTalk Server Application '$Name' exists."
}

<#
.SYNOPSIS
   Gets the Microsoft BizTalk Server Applications.
.DESCRIPTION
   Gets either one or all of the Microsoft BizTalk Server Applications as Microsoft.BizTalk.ExplorerOM.Application
   objects.
.PARAMETER Name
   The name of the Microsoft BizTalk Server Application.
.PARAMETER ManagementDatabaseServer
   The name of the SQL server hosting the management database; it defaults to MSBTS_GroupSetting.MgmtDbServerName.
.PARAMETER ManagementDatabaseName
   The name of the management database; it defaults to MSBTS_GroupSetting.MgmtDbName.
.OUTPUTS
   Returns the Microsoft BizTalk Server Applications.
.EXAMPLE
   PS> Get-BizTalkApplication
.EXAMPLE
   PS> Get-BizTalkApplication -Name 'BizTalk.System'
.NOTES
   © 2022 be.stateless.
#>
function Get-BizTalkApplication {
   [CmdletBinding()]
   [OutputType([Microsoft.BizTalk.ExplorerOM.Application[]])]
   param(
      [Parameter(Position = 0, Mandatory = $false)]
      [AllowEmptyString()]
      [AllowNull()]
      [string]
      $Name,

      [Parameter(Position = 1, Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $ManagementDatabaseServer = (Get-BizTalkGroupMgmtDbServer),

      [Parameter(Position = 2, Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $ManagementDatabaseName = (Get-BizTalkGroupMgmtDbName)
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
   Use-Object ($catalog = Get-BizTalkCatalog $ManagementDatabaseServer $ManagementDatabaseName) {
      if ([string]::IsNullOrWhiteSpace($Name)) {
         $catalog.Applications
      } else {
         $catalog.Applications[$Name]
      }
   }
}

<#
.SYNOPSIS
   Creates a new Microsoft BizTalk Server Application if it does not already exist.
.DESCRIPTION
   Creates a new Microsoft BizTalk Server Application if it does not already exist, as a Microsoft.BizTalk.ExplorerOM.Application object, along with its references to
   other existing Microsoft BizTalk Server Applications.
.PARAMETER Name
   The name of the Microsoft BizTalk Server Application to create.
.PARAMETER Description
   The description of the Microsoft BizTalk Server Application to create.
.PARAMETER Reference
   The names of the other Microsoft BizTalk Server Applications that have to be referenced from the application to create.
.OUTPUTS
   Returns the newly created Microsoft BizTalk Server Application.
.EXAMPLE
   PS> New-BizTalkApplication -Name BizTalk.Factory
.EXAMPLE
   PS> New-BizTalkApplication -Name BizTalk.Factory -Description 'BizTalk.Factory''s batching application add-on.' -References BizTalk.Factory, BizTalk.System
.NOTES
   © 2022 be.stateless.
#>
function New-BizTalkApplication {
   [CmdletBinding(SupportsShouldProcess = $true)]
   [OutputType([Microsoft.BizTalk.ExplorerOM.Application])]
   param(
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $Name,

      [Parameter(Position = 1, Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $Description,

      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Reference
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
   if (Test-BizTalkApplication -Name $Name) {
      Write-Information -MessageData "`t Microsoft BizTalk Server Application '$Name' has already been created."
   } elseif ($PsCmdlet.ShouldProcess($globalMessages.Should_Target, "Creating application '$Name'")) {
      Write-Information -MessageData "`t Creating Microsoft BizTalk Server Application '$Name'..."
      Use-Object ($catalog = Get-BizTalkCatalog ) {
         try {
            $application = $catalog.AddNewApplication()
            $application.Name = $Name
            if (![string]::IsNullOrWhiteSpace($Description)) { $application.Description = $Description }
            if ($Reference | Test-Any) {
               $Reference | ForEach-Object -Process {
                  Assert-BizTalkApplication -Name $_
                  $dependantApplication = $catalog.Applications[$_]
                  Write-Information -MessageData "`t Adding Reference to Microsoft BizTalk Server Application '$_' from Microsoft BizTalk Server Application '$Name'."
                  $application.AddReference($dependantApplication)
               }
            }
            $catalog.SaveChanges()
            $application
         } catch {
            $catalog.DiscardChanges()
            throw
         }
      }
      Write-Information -MessageData "`t Microsoft BizTalk Server Application '$Name' has been created."
   }
}

<#
.SYNOPSIS
   Deletes a Microsoft BizTalk Server Application if it does exists.
.DESCRIPTION
   Deletes a Microsoft BizTalk Server Application if it does exists.
.PARAMETER Name
   The name of the Microsoft BizTalk Server Application to delete.
.EXAMPLE
   PS> Remove-BizTalkApplication -Name BizTalk.Factory
.NOTES
   © 2022 be.stateless.
#>
function Remove-BizTalkApplication {
   [CmdletBinding(SupportsShouldProcess = $true)]
   [OutputType([void])]
   param(
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $Name
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
   if (-not(Test-BizTalkApplication -Name $Name)) {
      Write-Information -MessageData "`t Microsoft BizTalk Server Application '$Name' has already been removed."
   } elseif ($PsCmdlet.ShouldProcess($globalMessages.Should_Target, "Removing application '$Name'")) {
      Write-Information -MessageData "`t Removing Microsoft BizTalk Server Application '$Name'..."
      Invoke-Tool -Command { BTSTask RemoveApp -ApplicationName:`"$Name`" }
      Write-Information -MessageData "`t Microsoft BizTalk Server Application '$Name' has been removed."
   }
}

<#
.SYNOPSIS
   Starts a Microsoft BizTalk Server Application.
.DESCRIPTION
   Starts the given artifacts of a Microsoft BizTalk Server Application.
.PARAMETER Name
   The name of the Microsoft BizTalk Server Application to start.
.PARAMETER StartOptions
   The set of artifacts to start, see https://docs.microsoft.com/en-us/dotnet/api/microsoft.biztalk.explorerom.applicationstartoption. It defaults to
   StartAllOrchestrations, StartAllSendPorts, StartAllSendPortGroups, EnableAllReceiveLocations, DeployAllPolicies. It basically starts every application's
   artifacts except the referenced applications.
.PARAMETER ManagementDatabaseServer
   The name of the SQL server hosting the management database; it defaults to MSBTS_GroupSetting.MgmtDbServerName.
.PARAMETER ManagementDatabaseName
   The name of the management database; it defaults to MSBTS_GroupSetting.MgmtDbName.
.EXAMPLE
   PS> Start-BizTalkApplication -Name BizTalk.Factory
.EXAMPLE
   PS> Start-BizTalkApplication -Name BizTalk.Factory -StartOptions StartAllOrchestrations, StartAllSendPorts
.NOTES
   © 2022 be.stateless.
#>
function Start-BizTalkApplication {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $Name,

      [Parameter(Position = 1, Mandatory = $false)]
      [ApplicationStartOption]
      $StartOptions = (
         [ApplicationStartOption]::StartAllOrchestrations -bor
         [ApplicationStartOption]::StartAllSendPorts -bor
         [ApplicationStartOption]::StartAllSendPortGroups -bor
         [ApplicationStartOption]::EnableAllReceiveLocations -bor
         [ApplicationStartOption]::DeployAllPolicies
      ),

      [Parameter(Position = 3, Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $ManagementDatabaseServer = (Get-BizTalkGroupMgmtDbServer),

      [Parameter(Position = 4, Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $ManagementDatabaseName = (Get-BizTalkGroupMgmtDbName)
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
   Use-Object ($catalog = Get-BizTalkCatalog $ManagementDatabaseServer $ManagementDatabaseName) {
      $application = $catalog.Applications[$Name]
      try {
         $application.Start($StartOptions)
         $catalog.SaveChanges()
      } catch {
         $catalog.DiscardChanges()
         throw
      }
   }
}

<#
.SYNOPSIS
   Stops a Microsoft BizTalk Server Application.
.DESCRIPTION
   Stops the given artifacts of a Microsoft BizTalk Server Application.
.PARAMETER Name
   The name of the Microsoft BizTalk Server Application to stop.
.PARAMETER StopOptions
   The set of artifacts to stop, see https://docs.microsoft.com/en-us/dotnet/api/microsoft.biztalk.explorerom.applicationstopoption. It defaults to
   UnenlistAllOrchestrations, UnenlistAllSendPorts, UnenlistAllSendPortGroups, DisableAllReceiveLocations, UndeployAllPolicies. It basically stops every
   application's artifacts except the referenced applications.
.PARAMETER TerminateServiceInstances
   Whether to terminate any running or suspended Microsoft BizTalk Server service instances related to the application.
.PARAMETER ManagementDatabaseServer
   The name of the SQL server hosting the management database; it defaults to MSBTS_GroupSetting.MgmtDbServerName.
.PARAMETER ManagementDatabaseName
   The name of the management database; it defaults to MSBTS_GroupSetting.MgmtDbName.
.EXAMPLE
   PS> Stop-BizTalkApplication -Name BizTalk.Factory
.EXAMPLE
   PS> Stop-BizTalkApplication -Name BizTalk.Factory -StopOptions UnenlistAllOrchestrations, UnenlistAllSendPorts, DisableAllReceiveLocations
.EXAMPLE
   PS> Stop-BizTalkApplication -Name BizTalk.Factory -StopOptions UnenlistAllOrchestrations, UnenlistAllSendPorts, DisableAllReceiveLocations -TerminateServiceInstances
.NOTES
   © 2022 be.stateless.
#>
function Stop-BizTalkApplication {
   [CmdletBinding()]
   [OutputType([void])]
   param(
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $Name,

      [Parameter(Position = 1, Mandatory = $false)]
      [ApplicationStopOption]
      $StopOptions = (
         [ApplicationStopOption]::UnenlistAllOrchestrations -bor
         [ApplicationStopOption]::UnenlistAllSendPorts -bor
         [ApplicationStopOption]::UnenlistAllSendPortGroups -bor
         [ApplicationStopOption]::DisableAllReceiveLocations -bor
         [ApplicationStopOption]::UndeployAllPolicies
      ),

      [Parameter(Position = 2, Mandatory = $false)]
      [switch]
      $TerminateServiceInstances,

      [Parameter(Position = 3, Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $ManagementDatabaseServer = (Get-BizTalkGroupMgmtDbServer),

      [Parameter(Position = 4, Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $ManagementDatabaseName = (Get-BizTalkGroupMgmtDbName)
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
   Use-Object ($controller = Get-BizTalkController $ManagementDatabaseServer $ManagementDatabaseName) {
      if ($TerminateServiceInstances) {
         $controller.GetServiceInstances() |
            ForEach-Object -Process { $_ -as [MessageBoxServiceInstance] } |
            Where-Object -FilterScript { $_.Application -eq $Name -and ($_.InstanceStatus -band ([InstanceStatus]::RunningAll -bor [InstanceStatus]::SuspendedAll)) } |
            ForEach-Object -Process {
               Write-Information -MessageData "Terminating service instance ['$($_.Class)', '$($_.ID)']."
               result = $controller.TerminateInstance($_.ID)
               if (result -ne [CompletionStatus]::Succeeded -and $_.Class -ne [ServiceClass::RoutingFailure]) {
                  throw "Cannot stop application '$Name': failed to terminate service instance ['$($_.Class)', '$($_.ID)']."
               }
            }
      }
      $hasInstance = $controller.GetServiceInstances() |
         ForEach-Object -Process { $_ -as [MessageBoxServiceInstance] } |
         Where-Object -FilterScript { $_.Application -eq $Name } |
         Test-Any
      if ($hasInstance) {
         throw "Cannot stop application '$Name' because it has running service instances."
      }
   }
   Use-Object ($catalog = Get-BizTalkCatalog $ManagementDatabaseServer $ManagementDatabaseName) {
      $application = $catalog.Applications[$Name]
      try {
         $application.Stop($StopOptions)
         $catalog.SaveChanges()
      } catch {
         $catalog.DiscardChanges()
         throw
      }
   }
}

<#
.SYNOPSIS
   Tests the existence of a Microsoft BizTalk Server Application.
.DESCRIPTION
   Tests the existence of a Microsoft BizTalk Server Application.
.PARAMETER Name
   The name of the Microsoft BizTalk Server Application.
.PARAMETER Reference
   The name of the Microsoft BizTalk Server Applications that are to be referenced by the one whose existence is
   tested.
.PARAMETER ManagementDatabaseServer
   The name of the SQL server hosting the management database; it defaults to MSBTS_GroupSetting.MgmtDbServerName.
.PARAMETER ManagementDatabaseName
   The name of the management database; it defaults to MSBTS_GroupSetting.MgmtDbName.
.OUTPUTS
   Returns $true if the Microsoft BizTalk Server Application exists; $false otherwise.
.EXAMPLE
   PS> Test-BizTalkApplication
.EXAMPLE
   PS> Test-BizTalkApplication -Name 'BizTalk.System'
.NOTES
   © 2022 be.stateless.
#>
function Test-BizTalkApplication {
   [CmdletBinding()]
   [OutputType([bool])]
   param(
      [Parameter(Position = 0, Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [string]
      $Name,

      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Reference,

      [Parameter(Position = 1, Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $ManagementDatabaseServer = (Get-BizTalkGroupMgmtDbServer),

      [Parameter(Position = 2, Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [string]
      $ManagementDatabaseName = (Get-BizTalkGroupMgmtDbName)
   )
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
   Use-Object ($catalog = Get-BizTalkCatalog $ManagementDatabaseServer $ManagementDatabaseName) {
      $application = $catalog.Applications[$Name]
      if ($null -ne $application) {
         if ($Reference | Test-Any) {
            $actualReferences = @($application.References | ForEach-Object -Process { $_.Name })
            $Reference | Where-Object -FilterScript { $_ -notin $actualReferences } | Test-None
         } else {
            $true
         }
      } else {
         $false
      }
   }
}
