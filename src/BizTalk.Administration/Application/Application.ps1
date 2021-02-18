#region Copyright & License

# Copyright © 2012 - 2021 François Chabot
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
.PARAMETER References
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
    © 2020 be.stateless.
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
        $References,

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
        if ($References | Test-None) {
            throw "Microsoft BizTalk Server Application '$Name' does not exist."
        } else {
            throw "Microsoft BizTalk Server Application '$Name' does not exist or some the required application refereces '$($References -join ''', ''')' are missing."
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
        $References
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
                if ($References | Test-Any) {
                    $References | ForEach-Object -Process {
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
.PARAMETER References
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

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $References,

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
            if ($References | Test-Any) {
                $actualReferences = @($application.References | ForEach-Object -Process { $_.Name })
                $References | Where-Object -FilterScript { $_ -notin $actualReferences } | Test-None
            } else {
                $true
            }
        } else {
            $false
        }
    }
}
