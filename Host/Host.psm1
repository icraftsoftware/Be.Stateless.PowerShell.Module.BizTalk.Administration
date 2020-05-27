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

enum HostType {
    InProcess = [Microsoft.BizTalk.ExplorerOM.HostType]::InProcess
    Isolated = [Microsoft.BizTalk.ExplorerOM.HostType]::Isolated
}

<#
.SYNOPSIS
    Ensures a Microsoft BizTalk Server Host exists.
.DESCRIPTION
    This command will throw if the Microsoft BizTalk Server Host does not exist and will silently complete otherwise.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Host.
.EXAMPLE
    PS> Assert-BizTalkHost -Name 'Transmit Host'
.EXAMPLE
    PS> Assert-BizTalkHost -Name 'Transmit Host' -Verbose
.NOTES
    © 2020 be.stateless.
#>
function Assert-BizTalkHost {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    if (-not(Test-BizTalkHost -Name $Name)) {
        throw "Microsoft BizTalk Server Host '$Name' does not exist."
    }
    Write-Verbose "Microsoft BizTalk Server Host '$Name' exists."
}

<#
.SYNOPSIS
    Gets information about the Microsoft BizTalk Server Hosts.
.DESCRIPTION
    Gets either summary or detailed information about the Microsoft BizTalk Server Hosts.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Host.
.PARAMETER Detailed
    To get detailed, instead of summary, information about the Microsoft BizTalk Server Hosts.
.OUTPUTS
    Returns information about the Microsoft BizTalk Server Hosts.
.EXAMPLE
    PS> Get-BizTalkHost
.EXAMPLE
    PS> Get-BizTalkHost -Name 'Transmit Host'
.EXAMPLE
    PS> Get-BizTalkHost -Name 'Transmit Host' -Detailed
.NOTES
    © 2020 be.stateless.
#>
function Get-BizTalkHost {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Position = 0, Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]
        $Name,

        [Parameter(Mandatory = $false)]
        [switch]
        $Detailed
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    $className = if ($Detailed) { 'MSBTS_HostSetting' } else { 'MSBTS_Host' }
    $filter = if (![string]::IsNullOrWhiteSpace($Name)) {
        "Name='$Name'"
    }
    Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName $className -Filter $filter
}

<#
.SYNOPSIS
    Creates a new Microsoft BizTalk Server Host.
.DESCRIPTION
    Creates and configures a new Microsoft BizTalk Server Host.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Host.
.PARAMETER Type
    The type of the Microsoft BizTalk Server Host, either InProcess or Isolated.
.PARAMETER Group
    The Windows Domain Group used to control access of this host.
.PARAMETER x86
    Whether instances of this host will be 32-bit only processes.
.PARAMETER Default
    Whether this host is to be the default host in the Microsoft BizTalk Server Group or not.
.PARAMETER Tracking
    Wheter to enable the Microsoft BizTalk Server Tracking component for this host or not.
.PARAMETER Trusted
    Whether Microsoft BizTalk Server should trust this host or not.
.EXAMPLE
    PS> New-BizTalkHost -Name 'Transmit Host' -Type InProcess -Group 'BizTalk Application Users'
.EXAMPLE
    PS> New-BizTalkHost -Name 'Transmit Host' -Type InProcess -Group 'BizTalk Application Users' -x86
.EXAMPLE
    PS> New-BizTalkHost -Name 'Transmit Host' -Type InProcess -Group 'BizTalk Application Users' -x86:$false
.EXAMPLE
    PS> New-BizTalkHost -Name 'Transmit Host' -Type InProcess -Group 'BizTalk Application Users' -Verbose
.EXAMPLE
    PS> New-BizTalkHost -Name 'Transmit Host' -Type InProcess -Group 'BizTalk Application Users' -WhatIf
.LINK
    https://msdn.microsoft.com/en-us/library/aa560467.aspx, Creating, Updating, and Deleting a Host Instance Using WMI
.NOTES
    © 2020 be.stateless.
#>
function New-BizTalkHost {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [HostType]
        $Type,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Group,

        [Parameter(Mandatory = $false)]
        [switch]
        $x86,

        [Parameter(Mandatory = $false)]
        [switch]
        $Default,

        [Parameter(Mandatory = $false)]
        [switch]
        $Tracking,

        [Parameter(Mandatory = $false)]
        [switch]
        $Trusted
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    if (Test-BizTalkHost -Name $Name) {
        Write-Information "`t Microsoft BizTalk Server $Type '$Name' host has already been created."
    } elseif ($PsCmdlet.ShouldProcess("Microsoft BizTalk Server Group", "Creating $Type '$Name' host")) {
        Write-Information "`t Creating Microsoft BizTalk Server $Type '$Name' host with '$Group' Windows Domain Group..."
        $instanceClass = Get-CimClass -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostSetting
        $instance = New-CimInstance -ErrorAction Stop -CimClass $instanceClass -Property @{
            Name            = $Name
            HostType        = [Uint32]$Type
            NTGroupName     = $Group
            IsHost32BitOnly = [bool]$x86
            IsDefault       = [bool]$Default
            HostTracking    = [bool]$Tracking
            AuthTrusted     = [bool]$Trusted
        }
        Set-CimInstance -ErrorAction Stop -InputObject $instance
        Write-Information "`t Microsoft BizTalk Server $Type '$Name' host has been created."
    }
}

<#
.SYNOPSIS
    Removes a Microsoft BizTalk Server Host.
.DESCRIPTION
    Removes a Microsoft BizTalk Server Host.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Host.
.EXAMPLE
    PS> Remove-BizTalkHost -Name 'Transmit Host'
.NOTES
    © 2020 be.stateless.
#>
function Remove-BizTalkHost {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    if (-not(Test-BizTalkHost -Name $Name)) {
        Write-Information "`t Microsoft BizTalk Server '$Name' host has already been removed."
    } elseif ($PsCmdlet.ShouldProcess("Microsoft BizTalk Server Group", "Removing '$Name' host")) {
        Write-Information "`t Removing Microsoft BizTalk Server '$Name' host..."
        $instance = Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostSetting -Filter "Name='$Name'"
        Remove-CimInstance -ErrorAction Stop -InputObject $instance
        Write-Information "`t Microsoft BizTalk Server '$Name' host has been removed."
    }
}

<#
.SYNOPSIS
    Returns whether a Microsoft BizTalk Server Host type exists.
.DESCRIPTION
    This command will return $true if the Microsoft BizTalk Server Host exists; $false otherwise. The existence test
    can be narrowed down to a particular Type of Microsoft BizTalk Server Host, i.e. either InProcess or Isolated.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Host.
.PARAMETER Type
    The type of the Microsoft BizTalk Server Host.
.OUTPUTS
    $true if the Microsoft BizTalk Server Host exists and is of the given Type; $false otherwise.
.EXAMPLE
    PS> Test-BizTalkHost -Name 'Transmit Host'
.EXAMPLE
    PS> Test-BizTalkHost -Name 'Transmit Host' -Type Isolated
.NOTES
    © 2020 be.stateless.
#>
function Test-BizTalkHost {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $false)]
        [HostType]
        $Type
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    $btsHost = Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostSetting -Filter "Name='$Name'"
    [bool]$btsHost -and (-not $PSBoundParameters.ContainsKey('Type') -or $btsHost.HostType -eq $Type)
}

<#
.SYNOPSIS
    Updates the configuration settings of a Microsoft BizTalk Server Host.
.DESCRIPTION
    Updates the configuration settings of a Microsoft BizTalk Server Host.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Host.
.PARAMETER x86
    Whether instances of this host will be 32-bit only processes.
.PARAMETER Default
    Whether this host is to be the default host in the Microsoft BizTalk Server group or not.
.PARAMETER Tracking
    Wheter to enable the Microsoft BizTalk Server Tracking component for this host or not.
.PARAMETER Trusted
    Whether Microsoft BizTalk Server should trust this host or not.
.EXAMPLE
    PS> Update-BizTalkHost -Name 'Transmit Host' -x86 -Verbose
    With the -Verbose switch, this command will confirm this process is 32 bit.
.EXAMPLE
    PS> Update-BizTalkHost -Name 'Transmit Host' -x86 -Verbose -WhatIf
.EXAMPLE
    PS> Update-BizTalkHost -Name 'Transmit Host' -x86:$false -Verbose
    With the -Verbose switch, this command will confirm this process is not 32 bit.
.NOTES
    © 2020 be.stateless.
#>
function Update-BizTalkHost {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $false)]
        [bool]
        $x86,

        [Parameter(Mandatory = $false)]
        [switch]
        $Default,

        [Parameter(Mandatory = $false)]
        [bool]
        $Tracking,

        [Parameter(Mandatory = $false)]
        [bool]
        $Trusted
    )

    function Set-BizTalkHostProperty {
        [CmdletBinding(SupportsShouldProcess = $true)]
        [OutputType([void])]
        param(
            [Parameter(Mandatory = $true)]
            [string]
            $Name,

            [Parameter(Mandatory = $true)]
            [string]
            $Property,

            [Parameter(Mandatory = $true)]
            [object]
            $Value,

            [Parameter(Mandatory = $true)]
            [string]
            $ActionToPerform,

            [Parameter(Mandatory = $true)]
            [string]
            $PerformedAction
        )
        $instance = Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostSetting -Filter "Name='$Name'"
        if ($instance.$Property -ne $value -and $PsCmdlet.ShouldProcess("Microsoft BizTalk Server Group", $ActionToPerform)) {
            Write-Information "`t $ActionToPerform..."
            $instance.$Property = $Value
            Set-CimInstance -ErrorAction Stop -InputObject $instance
            Write-Information "`t $PerformedAction."
        }
    }

    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    if (Test-BizTalkHost -Name $Name) {
        if ($PSBoundParameters.ContainsKey('x86')) {
            $subject = "'$Name' host's 32-bit only restriction"
            Set-BizTalkHostProperty -Name $Name -Property IsHost32BitOnly -Value $x86 `
                -ActionToPerform ("{1} {0}" -f $Subject, (@('Enabling', 'Disabling')[!$x86])) `
                -PerformedAction ("{0} has been {1}" -f $Subject, (@('enabled', 'disabled')[!$x86]))
        }

        if ($Default.IsPresent -and -not $btsHost.IsDefault) {
            Set-BizTalkHostProperty -Name $Name -Property IsDefault -Value $Default `
                -ActionToPerform "Setting '$Name' host as default Microsoft BizTalk Server Group host" `
                -PerformedAction "'$Name' host has been set as default Microsoft BizTalk Server Group host"
        }

        if ($PSBoundParameters.ContainsKey('Tracking')) {
            $subject = "'$Name' host's Tracking capability"
            Set-BizTalkHostProperty -Name $Name -Property HostTracking -Value $Tracking `
                -ActionToPerform ("{1} {0}" -f $Subject, (@('Enabling', 'Disabling')[!$Tracking])) `
                -PerformedAction ("{0} has been {1}" -f $Subject, (@('enabled', 'disabled')[!$Tracking]))
        }

        if ($PSBoundParameters.ContainsKey('Trusted')) {
            $subject = "'$Name' host's Trusted Authentication"
            Set-BizTalkHostProperty -Name $Name -Property AuthTrusted -Value $Trusted `
                -ActionToPerform ("{1} {0}" -f $Subject, (@('Enabling', 'Disabling')[!$Trusted])) `
                -PerformedAction ("{0} has been {1}" -f $Subject, (@('enabled', 'disabled')[!$Trusted]))
        }
    } else {
        Write-Information "`t Microsoft BizTalk Server '$Name' host does not exist."
    }
}
