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

<#
.SYNOPSIS
    Asserts the existence of a Microsoft BizTalk Server Host Instance and whether it is in the expected state.
.DESCRIPTION
    This command will throw if the Microsoft BizTalk Server Host Instance does not exist, or is not in the expected
    state, and will silently complete otherwise.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Host.
.PARAMETER Server
    The server on which the Microsoft BizTalk Server Host Instance is tested for existence; it defaults to the
    local machine name.
.PARAMETER IsDisabled
    Whether the Microsoft BizTalk Server Host Instance must be disabled from starting as well.
.PARAMETER IsStarted
    Whether the Microsoft BizTalk Server Host Instance must be started as well.
.PARAMETER IsStopped
    Whether the Microsoft BizTalk Server Host Instance must be stopped as well.
.EXAMPLE
    PS> Assert-BizTalkHostInstance -Name 'Transmit Host'
.EXAMPLE
    PS> Assert-BizTalkHostInstance -Name 'Transmit Host' -IsStarted
.EXAMPLE
    PS> Assert-BizTalkHostInstance -Name 'Transmit Host' -IsDisabled -IsStopped
.EXAMPLE
    PS> Assert-BizTalkHostInstance -Name 'Transmit Host' -Server 'ComputerName'
.NOTES
    © 2020 be.stateless.
#>
function Assert-BizTalkHostInstance {
    [CmdletBinding(DefaultParameterSetName = 'no-service-state')]
    [OutputType([void])]
    param(
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'no-service-state')]
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'started-service-state')]
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'stopped-service-state')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = 'no-service-state')]
        [Parameter(Mandatory = $false, ParameterSetName = 'started-service-state')]
        [Parameter(Mandatory = $false, ParameterSetName = 'stopped-service-state')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server = $Env:COMPUTERNAME,

        [Parameter(Mandatory = $false, ParameterSetName = 'no-service-state')]
        [Parameter(Mandatory = $false, ParameterSetName = 'started-service-state')]
        [Parameter(Mandatory = $false, ParameterSetName = 'stopped-service-state')]
        [Switch]
        $IsDisabled,

        [Parameter(Mandatory = $true, ParameterSetName = 'started-service-state')]
        [Switch]
        $IsStarted,

        [Parameter(Mandatory = $true, ParameterSetName = 'stopped-service-state')]
        [Switch]
        $IsStopped
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    if (-not(Test-BizTalkHostInstance @PSBoundParameters)) {
        throw "Microsoft BizTalk Server '$Name' Host Instance on '$Server' server does not exist or is not in the expected state."
    }
    Write-Verbose "Microsoft BizTalk Server '$Name' Host Instance on '$Server' server exists and is in the expected state."
}

<#
.SYNOPSIS
    Disables a Microsoft BizTalk Server Host Instance.
.DESCRIPTION
    Disables a Microsoft BizTalk Server Host Instance.
.PARAMETER Name
    The name of the Microsoft BizTalk Host Instance to disable.
.PARAMETER Server
    The server on which run the Host Instance to disable; it defaults to the local machine name.
.EXAMPLE
    PS> Disable-BizTalkHostInstance -Name 'Transmit Host Instance'
    Disables the Microsoft BizTalk Server Host Instance named 'Transmit Host Instance' on the local machine.
.EXAMPLE
    PS> Disable-BizTalkHostInstance -Name 'Transmit Host Instance' -Server 'BizTalkBox'
    Disables the Microsoft BizTalk Server Host Instance named 'Transmit Host Instance' on the machine named
    'BizTalkBox'.
.NOTES
    © 2020 be.stateless.
#>
function Disable-BizTalkHostInstance {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server = $Env:COMPUTERNAME
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    if (-not(Test-BizTalkHostInstance -Name $Name -Server $Server)) {
        Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server does not exist."
    } elseif ($PsCmdlet.ShouldProcess("Microsoft BizTalk Server Group", "Disabling '$Name' Host Instance on '$Server' server")) {
        Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server is being disabled..."
        $hostInstance = Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance -Filter "HostName='$Name' and RunningServer='$Server'"
        $hostInstance.IsDisabled = $true
        Set-CimInstance -ErrorAction Stop -InputObject $hostInstance
        Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server has been disabled."
    }
}

<#
.SYNOPSIS
    Enables a Microsoft BizTalk Server Host Instance.
.DESCRIPTION
    Enables a Microsoft BizTalk Server Host Instance.
.PARAMETER Name
    The name of the Microsoft BizTalk Host Instance to enable.
.PARAMETER Server
    The server on which run the Host Instance to enable; it defaults to the local machine name.
.EXAMPLE
    PS> Enable-BizTalkHostInstance -Name 'Transmit Host Instance'
    Enables the Microsoft BizTalk Server Host Instance named 'Transmit Host Instance' on the local machine.
.EXAMPLE
    PS> Enable-BizTalkHostInstance -Name 'Transmit Host Instance' -Server 'BizTalkBox'
    Enables the Microsoft BizTalk Server Host Instance named 'Transmit Host Instance' on the machine named
    'BizTalkBox'.
.NOTES
    © 2020 be.stateless.
#>
function Enable-BizTalkHostInstance {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server = $Env:COMPUTERNAME
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    if (-not(Test-BizTalkHostInstance -Name $Name -Server $Server)) {
        Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server does not exist."
    } elseif ($PsCmdlet.ShouldProcess("Microsoft BizTalk Server Group", "Disabling '$Name' Host Instance on '$Server' server")) {
        Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server is being enabled..."
        $hostInstance = Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance -Filter "HostName='$Name' and RunningServer='$Server'"
        $hostInstance.IsDisabled = $false
        Set-CimInstance -ErrorAction Stop -InputObject $hostInstance
        Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server has been enabled."
    }
}

<#
.SYNOPSIS
    Gets information about Microsoft BizTalk Server Host Instances.
.DESCRIPTION
    Gets information about Microsoft BizTalk Server Host Instances.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Host Instance.
.PARAMETER Server
    The server on which the Microsoft BizTalk Server Host Instances run.
.OUTPUTS
    Returns information about the Microsoft BizTalk Server Host Instances.
.EXAMPLE
    PS> Get-BizTalkHostInstance
.EXAMPLE
    PS> Get-BizTalkHostInstance -Name BizTalkServerApplication
.EXAMPLE
    PS> Get-BizTalkHostInstance -Server $Env:COMPUTERNAME
.EXAMPLE
    PS> Get-BizTalkHostInstance -Name BizTalkServerApplication -Server $Env:COMPUTERNAME
.NOTES
    © 2020 be.stateless.
#>
function Get-BizTalkHostInstance {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]
        $Name,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]
        $Server
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    $filter = if (![string]::IsNullOrWhiteSpace($Name) -and ![string]::IsNullOrWhiteSpace($Server)) {
        "HostName='$Name' and RunningServer='$Server'"
    } elseif (![string]::IsNullOrWhiteSpace($Name)) {
        "HostName='$Name'"
    } elseif (![string]::IsNullOrWhiteSpace($Server)) {
        "RunningServer='$Server'"
    }
    Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance -Filter $filter
}

<#
.SYNOPSIS
    Creates a new Microsoft BizTalk Server Host Instance.
.DESCRIPTION
    Creates a new Microsoft BizTalk Server Host Instance.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Host Instance.
.PARAMETER User
    The user name, or logon, of the Windows account that the host intance to create will use to run.
.PARAMETER Password
    The password of the Windows account that the host intance to create will use to run.
.PARAMETER Server
    The server on which will run the Microsoft BizTalk Server Host Instance to create; it defaults to the local
    machine name.
.PARAMETER Started
    Whether to start this Microsoft BizTalk Server Host Instance upon creation.
.EXAMPLE
    PS> New-BizTalkHost -Name 'Transmit Host' -Type InProcess -Group 'BizTalk Application Users'
.EXAMPLE
    PS> New-BizTalkHost -Name 'Transmit Host' -Type InProcess -Group 'BizTalk Application Users' -Verbose
.EXAMPLE
    PS> New-BizTalkHost -Name 'Transmit Host' -Type InProcess -Group 'BizTalk Application Users' -WhatIf
.EXAMPLE
    PS> New-BizTalkHost -Name 'Transmit Host' -Trusted:$false
.LINK
    https://docs.microsoft.com/en-us/biztalk/core/technical-reference/mapping-and-installing-host-instances-using-wmi
.LINK
    https://sandroaspbiztalkblog.wordpress.com/2013/09/05/powershell-to-configure-biztalk-server-host-and-host-instances-according-to-some-of-the-best-practices/
.LINK
    https://www.powershellgallery.com/packages/BizTalkServer
.NOTES
    © 2020 be.stateless.
#>
function New-BizTalkHostInstance {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-BizTalkHost -Name $_ })]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $User,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Password,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server = $Env:COMPUTERNAME,

        # TODO is meaningless for Isolated Host
        [switch]
        $Disabled,

        # TODO is meaningless for Isolated Host
        [switch]
        $Started
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    if (Test-BizTalkHostInstance -Name $Name -Server $Server) {
        Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server has already been created."
    } elseif ($PsCmdlet.ShouldProcess("Microsoft BizTalk Server Group", "Creating '$Name' Host Instance on '$Server' server")) {
        Assert-Elevated
        try {
            Write-Information "`t Creating Microsoft BizTalk Server '$Name' Host Instance on '$Server' server..."
            $serverHostInstanceClass = Get-CimClass -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_ServerHost
            $serverHostInstance = New-CimInstance -ErrorAction Stop -CimClass $serverHostInstanceClass -ClientOnly -Property @{
                ServerName           = $Server
                HostName             = $Name
                MgmtDbNameOverride   = ''
                MgmtDbServerOverride = ''
            }
            Invoke-CimMethod -ErrorAction Stop -InputObject $serverHostInstance -MethodName Map -Arguments @{ } | Out-Null

            $hostInstanceClass = Get-CimClass -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance
            $hostInstance = New-CimInstance -ErrorAction Stop -CimClass $hostInstanceClass -ClientOnly -Property @{
                Name                 = "Microsoft BizTalk Server $Name $Server"
                HostName             = $Name
                MgmtDbNameOverride   = ''
                MgmtDbServerOverride = ''
            }

            $arguments = @{ GrantLogOnAsService = $true ; Logon = $User ; Password = $Password }
            if (Test-GmsaAccountSupport) { $arguments.IsGmsaAccount = $false }
            Invoke-CimMethod -ErrorAction Stop -InputObject $hostInstance -MethodName Install -Arguments $arguments | Out-Null

            if (Test-BizTalkHost -Name $Name -Type InProcess) {
                if ($Disabled.IsPresent) {
                    $hostInstance = Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance -Filter "HostName='$Name' and RunningServer='$Server'"
                    $hostInstance.IsDisabled = [bool]$Disabled
                    # $hostInstance |
                    Set-CimInstance -ErrorAction Stop -InputObject $hostInstance
                } elseif ($Started) {
                    Invoke-CimMethod -ErrorAction Stop -InputObject $hostInstance -MethodName Start -Arguments @{ } | Out-Null
                } else {
                    Invoke-CimMethod -ErrorAction Stop -InputObject $hostInstance -MethodName Stop -Arguments @{ } | Out-Null
                }
            }
            Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server has been created."
        } catch {
            Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server could not be created. Partially created objects will be attempted to be cleaned up."
            Remove-BizTalkHostInstance -Name $Name
            throw
        }
    }
}

<#
.SYNOPSIS
    Removes a new Microsoft BizTalk Server Host Instance.
.DESCRIPTION
    Removes a new Microsoft BizTalk Server Host Instance.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Host Instance to remove.
.PARAMETER Server
    The server of the Microsoft BizTalk Server Host Instance to remove; it defaults to the local machine name.
.EXAMPLE
    PS> Remove-BizTalkHostInstance -Name 'Transmit Host Instance'
    Removes the Microsoft BizTalk Server Host Instance named 'Transmit Host Instance' on the local machine.
.EXAMPLE
    PS> Remove-BizTalkHostInstance -Name 'Transmit Host Instance' -Server 'BizTalkBox'
    Removes the Microsoft BizTalk Server Host Instance named 'Transmit Host Instance' on the machine named
    'BizTalkBox'.
.LINK
    https://docs.microsoft.com/en-us/biztalk/core/technical-reference/uninstalling-and-un-mapping-a-host-instance-using-wmi
.LINK
    https://www.powershellgallery.com/packages/BizTalkServer
.NOTES
    © 2020 be.stateless.
#>
function Remove-BizTalkHostInstance {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server = $Env:COMPUTERNAME
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    if (-not(Test-BizTalkHostInstance -Name $Name -Server $Server)) {
        Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server has already been removed."
    } elseif ($PsCmdlet.ShouldProcess("Microsoft BizTalk Server Group", "Removing '$Name' Host Instance on '$Server' server")) {
        try {
            Write-Information "`t Removing Microsoft BizTalk Server '$Name' Host Instance on '$Server' server..."
            $hostInstance = Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance -Filter "HostName='$Name' and RunningServer='$Server'"
            # https://docs.microsoft.com/en-us/biztalk/core/technical-reference/msbts-hostinstance-configurationstate-property-wmi
            if ($null -ne $hostInstance -and $hostInstance.ConfigurationState -eq 1) {
                if (Test-BizTalkHost -Name $Name -Type InProcess) {
                    Invoke-CimMethod -ErrorAction Stop -InputObject $hostInstance -MethodName Stop -Arguments @{ } | Out-Null
                }
                Invoke-CimMethod -ErrorAction Stop -InputObject $hostInstance -MethodName Uninstall -Arguments @{ } | Out-Null
            }
            $serverHostInstance = Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_ServerHost -Filter "HostName='$Name' and ServerName='$Server'"
            if ($null -ne $serverHostInstance -and $serverHostInstance.IsMapped) {
                Invoke-CimMethod -ErrorAction Stop -InputObject $serverHostInstance -MethodName Unmap -Arguments @{ } | Out-Null
            }
            Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server has been removed."
        } catch {
            Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server could not be removed."
            throw
        }
    }
}

<#
.SYNOPSIS
    Restarts a running Microsoft BizTalk Server Host Instance.
.DESCRIPTION
    Restarts a running Microsoft BizTalk Server Host Instance. Unless the -Force switch is passed, this command has no
    effect if the Host Instance to restart is not already running. In other words, unless the -Force switch is passed,
    this command will never start a Host Instance that is not running.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Host Instance to restart.
.PARAMETER Server
    The server on which runs the Microsoft BizTalk Server Host Instance to restart; it defaults to the local
    machine name.
.PARAMETER Force
    Force a non running Microsoft BizTalk Server Host Instance to start.
.EXAMPLE
    PS> Restart-BizTalkHostInstance -Name 'Transmit Host Instance'
    Restarts the Microsoft BizTalk Server Host Instance named 'Transmit Host Instance' on the local machine.
.EXAMPLE
    PS> Restart-BizTalkHostInstance -Name 'Transmit Host Instance' -Force -Server 'BizTalkBox'
    Restarts or start the Microsoft BizTalk Server Host Instance named 'Transmit Host Instance' on the machine named
    'BizTalkBox'.
.NOTES
    © 2020 be.stateless.
#>
function Restart-BizTalkHostInstance {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server = $Env:COMPUTERNAME,

        [Parameter(Mandatory = $false)]
        [switch]
        $Force
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    if (-not(Test-BizTalkHostInstance -Name $Name -Server $Server)) {
        Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server does not exist."
    } elseif (Test-BizTalkHost -Name $Name -Type Isolated) {
        Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server is an Isolated Host and can neither be started nor stopped."
    } elseif ($PsCmdlet.ShouldProcess("Microsoft BizTalk Server Group", "Restarting '$Name' Host Instance on '$Server' server")) {
        $hostInstance = Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance -Filter "HostName='$Name' and RunningServer='$Server'"
        # https://docs.microsoft.com/en-us/biztalk/core/technical-reference/msbts-hostinstance-servicestate-property-wmi
        if ($Force -or $hostInstance.ServiceState -in @(2, 4) <# Sart Pending or Running #>) {
            Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server is being restarted..."
            Invoke-CimMethod -ErrorAction Stop -InputObject $hostInstance -MethodName Stop -Arguments @{ } | Out-Null
            Invoke-CimMethod -ErrorAction Stop -InputObject $hostInstance -MethodName Start -Arguments @{ } | Out-Null
            Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server has been restarted."
        } else {
            Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server does not need to be restarted as it is not running."
        }
    }
}

<#
.SYNOPSIS
    Starts a Microsoft BizTalk Server Host Instance.
.DESCRIPTION
    Starts a Microsoft BizTalk Server Host Instance.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Host Instance to start.
.PARAMETER Server
    The server on which run the Microsoft BizTalk Server Host Instance to start; it defaults to the local machine
    name.
.EXAMPLE
    PS> Start-BizTalkHostInstance -Name 'Transmit Host Instance'
    Starts the Microsoft BizTalk Server Host Instance named 'Transmit Host Instance' on the local machine.
.EXAMPLE
    PS> Start-BizTalkHostInstance -Name 'Transmit Host Instance' -Server 'BizTalkBox'
    Starts the Microsoft BizTalk Server Host Instance named 'Transmit Host Instance' on the machine named
    'BizTalkBox'.
.NOTES
    © 2020 be.stateless.
#>
function Start-BizTalkHostInstance {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server = $Env:COMPUTERNAME
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    if (-not(Test-BizTalkHostInstance -Name $Name -Server $Server)) {
        Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server does not exist."
    } elseif (Test-BizTalkHost -Name $Name -Type Isolated) {
        Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server is an Isolated Host and can neither be started nor stopped."
    } elseif ($PsCmdlet.ShouldProcess("Microsoft BizTalk Server Group", "Starting '$Name' Host Instance on '$Server' server")) {
        Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server is being started..."
        $hostInstance = Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance -Filter "HostName='$Name' and RunningServer='$Server'"
        Invoke-CimMethod -ErrorAction Stop -InputObject $hostInstance -MethodName Start -Arguments @{ } | Out-Null
        Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server has been started."
    }
}

<#
.SYNOPSIS
    Stops a Microsoft BizTalk Server Host Instance.
.DESCRIPTION
    Stops a Microsoft BizTalk Server Host Instance.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Host Instance to stop.
.PARAMETER Server
    The server on which run the Microsoft BizTalk Server Host Instance to stop; it defaults to the local machine
    name.
.EXAMPLE
    PS> Stop-BizTalkHostInstance -Name 'Transmit Host Instance'
    Stops the Microsoft BizTalk Server Host Instance named 'Transmit Host Instance' on the local machine.
.EXAMPLE
    PS> Stop-BizTalkHostInstance -Name 'Transmit Host Instance' -Server 'BizTalkBox'
    Stops sthe Microsoft BizTalk Server Host Instance named 'Transmit Host Instance' on the machine named
    'BizTalkBox'.
.NOTES
    © 2020 be.stateless.
#>
function Stop-BizTalkHostInstance {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server = $Env:COMPUTERNAME
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    if (-not(Test-BizTalkHostInstance -Name $Name -Server $Server)) {
        Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server does not exist."
    } elseif (Test-BizTalkHost -Name $Name -Type Isolated) {
        Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server is an Isolated Host and can neither be started nor stopped."
    } elseif ($PsCmdlet.ShouldProcess("Microsoft BizTalk Server Group", "Stopping '$Name' Host Instance on '$Server' server")) {
        Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server is being stopped..."
        $hostInstance = Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance -Filter "HostName='$Name' and RunningServer='$Server'"
        Invoke-CimMethod -ErrorAction Stop -InputObject $hostInstance -MethodName Stop -Arguments @{ } | Out-Null
        Write-Information "`t Microsoft BizTalk Server '$Name' Host Instance on '$Server' server has been stopped."
    }
}

<#
.SYNOPSIS
    Returns whether a Microsoft BizTalk Server Host Instance exists and whether it is started or stopped.
.DESCRIPTION
    This command will return $true if the Microsoft BizTalk Server Host Instance exists; $false otherwise. The
    existence test can be combined with the expected state of the Microsoft BizTalk Server Host Instance, i.e. either
    started or stopped.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Host.
.PARAMETER Server
    The server on which the Microsoft BizTalk Server Host Instance is tested for existence; it defaults to the
    local machine name.
.PARAMETER IsDisabled
    Whether the Microsoft BizTalk Server Host Instance must be disabled from starting as well.
.PARAMETER IsStarted
    Whether the Microsoft BizTalk Server Host Instance must be started as well.
.PARAMETER IsStopped
    Whether the Microsoft BizTalk Server Host Instance must be stopped as well.
.OUTPUTS
    Returns $true if the Microsoft BizTalk Server Host Instance exists; $false otherwise.
.EXAMPLE
    PS> Test-BizTalkHostInstance -Name 'Transmit Host'
.EXAMPLE
    PS> Test-BizTalkHostInstance -Name 'Transmit Host' -IsStarted
.EXAMPLE
    PS> Test-BizTalkHostInstance -Name 'Transmit Host' -IsDisabled -IsStopped
.EXAMPLE
    PS> Test-BizTalkHostInstance -Name 'Transmit Host' -Server 'ComputerName'
.NOTES
    © 2020 be.stateless.
#>
function Test-BizTalkHostInstance {
    [CmdletBinding(DefaultParameterSetName = 'no-service-state')]
    [OutputType([bool])]
    param(
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'no-service-state')]
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'started-service-state')]
        [Parameter(Position = 0, Mandatory = $true, ParameterSetName = 'stopped-service-state')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $false, ParameterSetName = 'no-service-state')]
        [Parameter(Mandatory = $false, ParameterSetName = 'started-service-state')]
        [Parameter(Mandatory = $false, ParameterSetName = 'stopped-service-state')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server = $Env:COMPUTERNAME,

        [Parameter(Mandatory = $false, ParameterSetName = 'no-service-state')]
        [Parameter(Mandatory = $false, ParameterSetName = 'started-service-state')]
        [Parameter(Mandatory = $false, ParameterSetName = 'stopped-service-state')]
        [Switch]
        $IsDisabled,

        [Parameter(Mandatory = $true, ParameterSetName = 'started-service-state')]
        [Switch]
        $IsStarted,

        [Parameter(Mandatory = $true, ParameterSetName = 'stopped-service-state')]
        [Switch]
        $IsStopped
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    $hostInstance = Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance -Filter "HostName='$Name' and RunningServer='$Server'"
    $doesMatchExpectedDisabledState = -not $PSBoundParameters.ContainsKey('IsDisabled') -or ($hostInstance -and $IsDisabled -eq $hostInstance.IsDisabled)
    switch ($PSCmdlet.ParameterSetName) {
        'no-service-state' { $hostInstance -and $doesMatchExpectedDisabledState }
        # https://docs.microsoft.com/en-us/biztalk/core/technical-reference/msbts-hostinstance-servicestate-property-wmi
        'started-service-state' { $hostInstance -and $doesMatchExpectedDisabledState -and (($IsStarted -and $hostInstance.ServiceState -eq 4) -or (-not $IsStarted -and $hostInstance.ServiceState -ne 4)) }
        'stopped-service-state' { $hostInstance -and $doesMatchExpectedDisabledState -and (($IsStopped -and $hostInstance.ServiceState -eq 1) -or (-not $IsStopped -and $hostInstance.ServiceState -ne 1)) }
    }
}

function Test-GmsaAccountSupport {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    if (-not(Get-Variable -Name IsGmsaAccountSupported -Scope Script -ErrorAction Ignore)) {
        $isSupported = Get-CimClass -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance |
            Select-Object -ExpandProperty CimClassMethods |
            Where-Object -FilterScript { $_.Name -eq 'Install' } |
            Select-Object -ExpandProperty Parameters |
            Where-Object -FilterScript { $_.Name -eq 'IsGmsaAccount' } |
            Test-Any
        New-Variable -Name IsGmsaAccountSupported -Option ReadOnly -Scope Script -Value $isSupported
    }
    $IsGmsaAccountSupported
}
