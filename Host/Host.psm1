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
    Ensures a Microsoft BizTalk Server host exists.
.DESCRIPTION
    This command will throw if the Microsoft BizTalk Server host does not exist and will silently complete otherwise.
.PARAMETER Name
    The name of the BizTalk Server host.
.EXAMPLE
    PS> Assert-BizTalkHost -Name 'Transmit Host'
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
    if (-not(Test-BizTalkHost -Name $Name)) {
        throw "Microsoft BizTalk Server Host '$Name' does not exist."
    }
    Write-Verbose "Microsoft BizTalk Server Host '$Name' exists."
}

<#
.SYNOPSIS
    Gets information about the Microsoft BizTalk Server hosts.
.DESCRIPTION
    Gets either summary or detailed information about either one or all of the Microsoft BizTalk Server hosts.
.PARAMETER Name
    The name of the BizTalk Server host.
.PARAMETER Detailed
    Indicates that this cmdlet gets detailed information about eihter one or all of the Microsoft BizTalk Server
    hosts.
.OUTPUTS
    Returns either summary or detailed information about the Microsoft BizTalk Server hosts.
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
    $className = if ($Detailed) { 'MSBTS_HostSetting' } else { 'MSBTS_Host' }
    $filter = if (![string]::IsNullOrWhiteSpace($Name)) {
        "Name='$Name'"
    }
    Get-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName $className -Filter $filter
}

<#
.SYNOPSIS
    Creates a new BizTalk Server host.
.DESCRIPTION
    Creates and configures a new BizTalk Server host.
.PARAMETER Name
    The name of the BizTalk Server host.
.PARAMETER Type
    The type of the BizTalk Server host, either InProcess or Isolated.
.PARAMETER Group
    The Windows group used to control access of this host.
.PARAMETER x86
    Whether instances of this host will be 32-bit only processes.
.PARAMETER Default
    Whether this host is to be the default host in the BizTalk Server group or not.
.PARAMETER Tracking
    Wheter to enable the BizTalk Tracking component for this host or not.
.PARAMETER Trusted
    Whether BizTalk should trust this host or not.
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
    if (Test-BizTalkHost -Name $Name) {
        Write-Host "`t '$Name' host already exists."
    } elseif ($PsCmdlet.ShouldProcess("BizTalk Group", "Creating $Type '$Name' host")) {
        Write-Verbose "`t Creating $Type '$Name' host with '$Group' Windows group..."
        try {
            # New-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostSetting -Property @{
            $instanceClass = Get-CimClass -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostSetting
            $instance = New-CimInstance -CimClass $instanceClass -Property @{
                Name            = $Name
                HostType        = [Uint32]$Type
                NTGroupName     = $Group
                IsHost32BitOnly = [bool]$x86
                IsDefault       = [bool]$Default
                HostTracking    = [bool]$Tracking
                AuthTrusted     = [bool]$Trusted
            }
            Set-CimInstance -InputObject $instance
            if ($?) {
                Write-Host "`t $Type '$Name' host has been created."
            } else {
                Write-Error "`t Creating '$Name' host has failed."
                throw "Creating '$Name' host has failed."
            }
        } catch {
            Write-Error "`t Creating '$Name' host has failed."
            throw;
        }
    }
}

<#
.SYNOPSIS
    Removes a BizTalk Server Host.
.DESCRIPTION
    Removes a BizTalk Server Host.
.PARAMETER Name
    The name of the BizTalk Server host.
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
    if (Test-BizTalkHost -Name $Name) {
        $instance = Get-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostSetting -Filter "Name='$Name'"
        if ($PsCmdlet.ShouldProcess("BizTalk Group", "Deleting '$Name' host")) {
            try {
                Remove-CimInstance -InputObject $instance
                Write-Host "`t '$Name' host has been deleted."
            } catch {
                Write-Error "`t Deleting '$Name' host has failed."
                throw;
            }
        }
    } else {
        Write-Host "`t '$Name' host does not exists."
    }
}

<#
.SYNOPSIS
    Returns whether a Microsoft BizTalk Server host exists.
.DESCRIPTION
    This command will return $true if the Microsoft BizTalk Server host exists; $false otherwise.
.PARAMETER Name
    The name of the BizTalk Server host.
.OUTPUTS
    True if the BizTalk Server host exists; False otherwise.
.EXAMPLE
    PS> Test-BizTalkHost -Name 'Transmit Host'
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
        $Name
    )
    [bool] (Get-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostSetting -Filter "Name='$Name'")
}

<#
.SYNOPSIS
    Updates the configuration settings of a BizTalk Server host.
.DESCRIPTION
    Updates the configuration settings of a BizTalk Server host.
.PARAMETER Name
    The name of the BizTalk Server host.
.PARAMETER x86
    Whether instances of this host will be 32-bit only processes.
.PARAMETER Default
    Whether this host is to be the default host in the BizTalk group or not.
.PARAMETER Tracking
    Wheter to enable the BizTalk Tracking component for this host or not.
.PARAMETER Trusted
    Whether BizTalk should trust this host or not.
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

        $instance = Get-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostSetting -Filter "Name='$Name'"
        if ($instance.$Property -ne $value -and $PsCmdlet.ShouldProcess("BizTalk Group", $ActionToPerform)) {
            Write-Verbose "`t $ActionToPerform..."
            $instance.$Property = $Value
            Set-CimInstance -InputObject $instance
            try {
                Set-CimInstance -InputObject $instance
                Write-Verbose "`t $PerformedAction."
            } catch {
                Write-Error "`t $ActionToPerform has failed."
                throw;
            }
        }
    }

    if (Test-BizTalkHost -Name $Name) {
        if ($PSBoundParameters.ContainsKey('x86')) {
            $subject = "'$Name' host's 32-bit only restriction"
            Set-BizTalkHostProperty -Name $Name -Property IsHost32BitOnly -Value $x86 `
                -ActionToPerform ("{1} {0}" -f $Subject, (@('Enabling', 'Disabling')[!$x86])) `
                -PerformedAction ("{0} has been {1}" -f $Subject, (@('enabled', 'disabled')[!$x86]))
        }

        if ($Default.IsPresent -and -not $btsHost.IsDefault) {
            Set-BizTalkHostProperty -Name $Name -Property IsDefault -Value $Default `
                -ActionToPerform "Setting '$Name' host as default BizTalk Group host" `
                -PerformedAction "'$Name' host has been set as default BizTalk Group host"
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
        Write-Host "`t '$Name' host does not exists."
    }
}
