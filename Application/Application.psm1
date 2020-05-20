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

using namespace Microsoft.BizTalk.ExplorerOM
using namespace Microsoft.BizTalk.Operations

Set-StrictMode -Version Latest

<#
.SYNOPSIS
    Gets the Microsoft BizTalk Server Applications.
.DESCRIPTION
    Gets either one or all of the Microsoft BizTalk Server Applications as Microsoft.BizTalk.ExplorerOM.Application
    objects.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Application.
.PARAMETER ManagementDatabaseServer
    The name of the SQL server hosting the management database; it is filled in by default with information found
    in the registry.
.PARAMETER ManagementDatabaseName
    The name of the management database; it is filled in by default with information found in the registry.
.OUTPUTS
    Returns the Microsoft BizTalk Server Applications.
.EXAMPLE
    PS> Get-BizTalkApplication
.EXAMPLE
    PS> Get-BizTalkApplication -Name 'BizTalk.System'
.NOTES
    © 2020 be.stateless.
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
        $ManagementDatabaseServer = (Get-BizTalGroupMgmtDbServer),

        [Parameter(Position = 2, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ManagementDatabaseName = (Get-BizTalGroupMgmtDbName)
    )
    Use-Object ($catalog = Get-BizTalkCatalog $ManagementDatabaseServer $ManagementDatabaseName) {
        if ([string]::IsNullOrWhiteSpace($Name)) {
            $catalog.Applications
        } else {
            $catalog.Applications[$Name]
        }
    }
}

function New-BizTalkApplication {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Position = 1, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Description
    )
    Invoke-Tool -Command { BTSTask AddApp -ApplicationName:"$Name" -Description:"$Description" }
}

function Remove-BizTalkApplication {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name
    )
    Invoke-Tool -Command { BTSTask RemoveApp -ApplicationName:"$Name" }
}

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
        $ManagementDatabaseServer = (Get-BizTalGroupMgmtDbServer),

        [Parameter(Position = 4, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ManagementDatabaseName = (Get-BizTalGroupMgmtDbName)
    )
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
        $ManagementDatabaseServer = (Get-BizTalGroupMgmtDbServer),

        [Parameter(Position = 4, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ManagementDatabaseName = (Get-BizTalGroupMgmtDbName)
    )
    Use-Object ($controller = Get-BizTalkController $ManagementDatabaseServer $ManagementDatabaseName) {
        if ($TerminateServiceInstances) {
            $controller.GetServiceInstances() |
                ForEach-Object -Process { $_ -as [ServiceInstance] } |
                Where-Object -FilterScript { $_.Application -eq $Name -and ($_.InstanceStatus -band ([InstanceStatus]::RunningAll -bor [InstanceStatus]::SuspendedAll)) } |
                ForEach-Object -Process {
                    Write-Information "Terminating service instance ['$($_.Class)', '$($_.ID)']."
                    result = $controller.TerminateInstance($_.ID)
                    if (result -ne [CompletionStatus]::Succeeded -and $_.Class -ne [ServiceClass::RoutingFailure]) {
                        throw "Cannot stop application '$Name': failed to terminate service instance ['$($_.Class)', '$($_.ID)']."
                    }
                }
        }
        $hasInstance = $controller.GetServiceInstances() |
            ForEach-Object -Process { $_ -as [ServiceInstance] } |
            Where-Object -FilterScript { $_.Application -eq $Name } |
            Test-Any
        if ($hasInstance) {
            throw "Cannot stop application '$Name' because it has running service intances."
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
    Tests the existence of a Microsoft BizTalk Server Applications.
.DESCRIPTION
    Tests the existence of a Microsoft BizTalk Server Applications.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Application.
.PARAMETER ManagementDatabaseServer
    The name of the SQL server hosting the management database; it is filled in by default with information found
    in the registry.
.PARAMETER ManagementDatabaseName
    The name of the management database; it is filled in by default with information found in the registry.
.OUTPUTS
    Returns $true if the Microsoft BizTalk Server Application exists; $false otherwise.
.EXAMPLE
    PS> Get-BizTalkApplication
.EXAMPLE
    PS> Get-BizTalkApplication -Name 'BizTalk.System'
.NOTES
    © 2020 be.stateless.
#>
function Test-BizTalkApplication {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Position = 1, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ManagementDatabaseServer = (Group\Get-BizTalGroupMgmtDbServer),

        [Parameter(Position = 2, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ManagementDatabaseName = (Group\Get-BizTalGroupMgmtDbName)
    )
    Use-Object ($catalog = Get-BizTalkCatalog $ManagementDatabaseServer $ManagementDatabaseName) {
        $null -ne $catalog.Applications[$Name]
    }
}

Add-ToolAlias -Path ($env:BTSINSTALLPATH) -Tool BTSTask

Import-Module BizTalk.Administration\Group
