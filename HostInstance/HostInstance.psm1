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
    Disables a Microsoft BizTalk Server host instance.
.DESCRIPTION
    Disables a Microsoft BizTalk Server host instance.
.PARAMETER Name
    The name of the Microsoft BizTalk host instance to disable.
.PARAMETER Server
    The server on which run the host instance to disable; it defaults to the local machine name.
.EXAMPLE
    PS> Disable-BizTalkHostInstance -Name 'Transmit Host Instance'
    Disables the Microsoft BizTalk Server host instance named 'Transmit Host Instance' on the local machine.
.EXAMPLE
    PS> Disable-BizTalkHostInstance -Name 'Transmit Host Instance' -Server 'BizTalkBox'
    Disables the Microsoft BizTalk Server host instance named 'Transmit Host Instance' on the machine named
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
    if (Test-BizTalkHostInstance -Name $Name -Server $Server) {
        if ($PsCmdlet.ShouldProcess("BizTalk Group", "Disabling '$Name' host instance on '$Server' server")) {
            Write-Verbose "`t '$Name' host instace on '$Server' server is being disabled..."
            $hostInstance = Get-CimInstance -Namespace root/MicrosoftBizTalkServer -Class MSBTS_HostInstance -Filter "Name='Microsoft BizTalk Server $Name $Server'"
            $hostInstance.IsDisabled = $true
            Set-CimInstance -InputObject $hostInstance
            Write-Verbose "`t '$Name' host instace on '$Server' server has been disabled."
        }
    } else {
        Write-Host "`t '$Name' host instance on '$Server' server does not exists."
    }
}

<#
.SYNOPSIS
    Enables a Microsoft BizTalk Server host instance.
.DESCRIPTION
    Enables a Microsoft BizTalk Server host instance.
.PARAMETER Name
    The name of the Microsoft BizTalk host instance to enable.
.PARAMETER Server
    The server on which run the host instance to enable; it defaults to the local machine name.
.EXAMPLE
    PS> Enable-BizTalkHostInstance -Name 'Transmit Host Instance'
    Enables the Microsoft BizTalk Server host instance named 'Transmit Host Instance' on the local machine.
.EXAMPLE
    PS> Enable-BizTalkHostInstance -Name 'Transmit Host Instance' -Server 'BizTalkBox'
    Enables the Microsoft BizTalk Server host instance named 'Transmit Host Instance' on the machine named
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
    if (Test-BizTalkHostInstance -Name $Name -Server $Server) {
        if ($PsCmdlet.ShouldProcess("BizTalk Group", "Disabling '$Name' host instance on '$Server' server")) {
            Write-Verbose "`t '$Name' host instace on '$Server' server is being enabled..."
            $hostInstance = Get-CimInstance -Namespace root/MicrosoftBizTalkServer -Class MSBTS_HostInstance -Filter "Name='Microsoft BizTalk Server $Name $Server'"
            $hostInstance.IsDisabled = $false
            Set-CimInstance -InputObject $hostInstance
            Write-Verbose "`t '$Name' host instace on '$Server' server has been enabled."
        }
    } else {
        Write-Host "`t '$Name' host instance on '$Server' server does not exists."
    }
}

<#
.SYNOPSIS
    Gets information about Microsoft BizTalk Server host instances.
.DESCRIPTION
    Gets information about Microsoft BizTalk Server host instances.
.PARAMETER Name
    The name of the Microsoft BizTalk Server host instance.
.PARAMETER Server
    The server on which the Microsoft BizTalk Server host instances run.
.OUTPUTS
    Returns information about the Microsoft BizTalk Server host instances.
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
    $filter = if (![string]::IsNullOrWhiteSpace($Name) -and ![string]::IsNullOrWhiteSpace($Server)) {
        "HostName='$Name' and RunningServer='$Server'"
    } elseif (![string]::IsNullOrWhiteSpace($Name)) {
        "HostName='$Name'"
    } elseif (![string]::IsNullOrWhiteSpace($Server)) {
        "RunningServer='$Server'"
    }
    Get-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance -Filter $filter
}

<#
.SYNOPSIS
    Creates a new Microsoft BizTalk Server host instance.
.DESCRIPTION
    Creates and configures a new Microsoft BizTalk Server host instance.
.PARAMETER Name
    The name of the Microsoft BizTalk Server host instance.
.PARAMETER User
    The user name, or logon, of the windows account that the host intance to create will use to run.
.PARAMETER Password
    The password of the windows account that the host intance to create will use to run.
.PARAMETER Server
    The server on which will run the Microsoft BizTalk Server host instance to create; it defaults to the local
    machine name.
.PARAMETER Started
    Whether to start this Microsoft BizTalk Server host instance upon creation.
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

        [switch]
        $Disabled,

        [switch]
        $Started
    )
    if (Test-BizTalkHostInstance -Name $Name -Server $Server) {
        Write-Host "`t '$Name' host instance on '$Server' server already exists."
    } elseif ($PsCmdlet.ShouldProcess("BizTalk Group", "Creating '$Name' host instance on '$Server' server")) {
        Assert-BizTalkHost -Name $Name
        Assert-Elevated
        Write-Verbose "`t Creating '$Name' host instance on '$Server' server..."
        $serverHostInstanceClass = Get-CimClass -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_ServerHost
        $serverHostInstance = New-CimInstance -CimClass $serverHostInstanceClass -ClientOnly -Property @{
            ServerName           = $Server
            HostName             = $Name
            MgmtDbNameOverride   = ''
            MgmtDbServerOverride = ''
        }
        Invoke-CimMethod -InputObject $serverHostInstance -MethodName Map -Arguments @{ } | Out-Null

        $hostInstanceClass = Get-CimClass -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance
        $hostInstance = New-CimInstance -CimClass $hostInstanceClass -ClientOnly -Property @{
            Name                 = "Microsoft BizTalk Server $Name $Server"
            HostName             = $Name
            MgmtDbNameOverride   = ''
            MgmtDbServerOverride = ''
        }
        Invoke-CimMethod -InputObject $hostInstance -MethodName Install -Arguments @{
            GrantLogOnAsService = $true
            IsGmsaAccount       = $false
            Logon               = $User
            Password            = $Password
        } | Out-Null

        if ($Disabled.IsPresent) {
            $hostInstance = Get-CimInstance -Namespace root/MicrosoftBizTalkServer -Class MSBTS_HostInstance -Filter "Name='Microsoft BizTalk Server $Name $Server'"
            $hostInstance.IsDisabled = [bool]$Disabled
            $hostInstance | Set-CimInstance
        } elseif ($Started) {
            Invoke-CimMethod -InputObject $hostInstance -MethodName Start -Arguments @{ } | Out-Null
        } else {
            Invoke-CimMethod -InputObject $hostInstance -MethodName Stop -Arguments @{ } | Out-Null
        }
        Write-Host "`t '$Name' host instance on '$Server' server has been created."
    }
}

<#
.SYNOPSIS
    Removes a Microsoft BizTalk Server instance.
.DESCRIPTION
    Removes a Microsoft BizTalk Server host instance.
.PARAMETER Name
    The name of the Microsoft BizTalk Server host instance to remove.
.PARAMETER Server
    The server of the Microsoft BizTalk Server host instance to remove; it defaults to the local machine name.
.EXAMPLE
    PS> Remove-BizTalkHostInstance -Name 'Transmit Host Instance'
    Removes the Microsoft BizTalk Server host instance named 'Transmit Host Instance' on the local machine.
.EXAMPLE
    PS> Remove-BizTalkHostInstance -Name 'Transmit Host Instance' -Server 'BizTalkBox'
    Removes the Microsoft BizTalk Server host instance named 'Transmit Host Instance' on the machine named
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
    if (Test-BizTalkHostInstance -Name $Name -Server $Server) {
        if ($PsCmdlet.ShouldProcess("BizTalk Group", "Deleting '$Name' host instance on '$Server' server")) {
            try {
                $hostInstance = Get-CimInstance -Namespace root/MicrosoftBizTalkServer -Class MSBTS_HostInstance -Filter "Name='Microsoft BizTalk Server $Name $Server'"
                Invoke-CimMethod -InputObject $hostInstance -MethodName Stop -Arguments @{ } | Out-Null
                Invoke-CimMethod -InputObject $hostInstance -MethodName Uninstall -Arguments @{ } | Out-Null

                $serverHostInstance = Get-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_ServerHost -Filter "ServerName='$Server' and HostName='$Name'"
                Invoke-CimMethod -InputObject $serverHostInstance -MethodName UnMap -Arguments @{ } | Out-Null

                Write-Host "`t '$Name' host has been deleted."
            } catch {
                Write-Error "`t Deleting '$Name' host has failed."
                throw
            }
        }
    } else {
        Write-Host "`t '$Name' host instance on '$Server' server does not exists."
    }
}

<#
.SYNOPSIS
    Restarts a running Microsoft BizTalk Server host instance.
.DESCRIPTION
    Restarts a running Microsoft BizTalk Server host instance. Unless the -Force switch is passed, this command has no
    effect if the host instance to restart is not already running. In other words, unless the -Force switch is passed,
    this command will never start a host instance that is not running.
.PARAMETER Name
    The name of the Microsoft BizTalk Server host instance to restart.
.PARAMETER Server
    The server on which run the Microsoft BizTalk Server host instance to restart; it defaults to the local
    machine name.
.PARAMETER Force
    Force a non running Microsoft BizTalk Server host instance to start.
.EXAMPLE
    PS> Restart-BizTalkHostInstance -Name 'Transmit Host Instance'
    Restarts the Microsoft BizTalk Server host instance named 'Transmit Host Instance' on the local machine.
.EXAMPLE
    PS> Restart-BizTalkHostInstance -Name 'Transmit Host Instance' -Force -Server 'BizTalkBox'
    Restarts or start the Microsoft BizTalk Server host instance named 'Transmit Host Instance' on the machine named
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
    if (Test-BizTalkHostInstance -Name $Name -Server $Server) {
        if ($PsCmdlet.ShouldProcess("BizTalk Group", "Restarting '$Name' host instance on '$Server' server")) {
            $hostInstance = Get-CimInstance -Namespace root/MicrosoftBizTalkServer -Class MSBTS_HostInstance -Filter "Name='Microsoft BizTalk Server $Name $Server'"
            # https://docs.microsoft.com/en-us/biztalk/core/technical-reference/msbts-hostinstance-servicestate-property-wmi
            if ($Force -or $hostInstance.ServiceState -in @(2, 4) <# Sart Pending or Running #>) {
                Write-Verbose "`t '$Name' host instace on '$Server' server is being restarted..."
                Invoke-CimMethod -InputObject $hostInstance -MethodName Stop -Arguments @{ } | Out-Null
                Invoke-CimMethod -InputObject $hostInstance -MethodName Start -Arguments @{ } | Out-Null
                Write-Verbose "`t '$Name' host instace on '$Server' server has been restarted."
            } else {
                Write-Verbose "`t '$Name' host instace on '$Server' server does not need to be restarted as it is not started."
            }
        }
    } else {
        Write-Host "`t '$Name' host instance on '$Server' server does not exists."
    }
}

<#
.SYNOPSIS
    Starts a Microsoft BizTalk Server host instance.
.DESCRIPTION
    Starts a Microsoft BizTalk Server host instance.
.PARAMETER Name
    The name of the Microsoft BizTalk Server host instance to start.
.PARAMETER Server
    The server on which run the Microsoft BizTalk Server host instance to start; it defaults to the local machine
    name.
.EXAMPLE
    PS> Start-BizTalkHostInstance -Name 'Transmit Host Instance'
    Starts the Microsoft BizTalk Server host instance named 'Transmit Host Instance' on the local machine.
.EXAMPLE
    PS> Start-BizTalkHostInstance -Name 'Transmit Host Instance' -Server 'BizTalkBox'
    Starts the Microsoft BizTalk Server host instance named 'Transmit Host Instance' on the machine named
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
    if (Test-BizTalkHostInstance -Name $Name -Server $Server) {
        if ($PsCmdlet.ShouldProcess("BizTalk Group", "Starting '$Name' host instance on '$Server' server")) {
            Write-Verbose "`t '$Name' host instace on '$Server' server is being started..."
            $hostInstance = Get-CimInstance -Namespace root/MicrosoftBizTalkServer -Class MSBTS_HostInstance -Filter "Name='Microsoft BizTalk Server $Name $Server'"
            Invoke-CimMethod -InputObject $hostInstance -MethodName Start -Arguments @{ } | Out-Null
            Write-Verbose "`t '$Name' host instace on '$Server' server has been started."
        }
    } else {
        Write-Host "`t '$Name' host instance on '$Server' server does not exists."
    }
}

<#
.SYNOPSIS
    Stops a Microsoft BizTalk Server host instance.
.DESCRIPTION
    Stops a Microsoft BizTalk Server host instance.
.PARAMETER Name
    The name of the Microsoft BizTalk Server host instance to stop.
.PARAMETER Server
    The server on which run the Microsoft BizTalk Server host instance to stop; it defaults to the local machine
    name.
.EXAMPLE
    PS> Stop-BizTalkHostInstance -Name 'Transmit Host Instance'
    Stops the Microsoft BizTalk Server host instance named 'Transmit Host Instance' on the local machine.
.EXAMPLE
    PS> Stop-BizTalkHostInstance -Name 'Transmit Host Instance' -Server 'BizTalkBox'
    Stops sthe Microsoft BizTalk Server host instance named 'Transmit Host Instance' on the machine named
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
    if ($PsCmdlet.ShouldProcess("BizTalk Group", "Stopping '$Name' host instance on '$Server' server")) {
        Write-Verbose "`t '$Name' host instace on '$Server' server is being stopped..."
        $hostInstance = Get-CimInstance -Namespace root/MicrosoftBizTalkServer -Class MSBTS_HostInstance -Filter "Name='Microsoft BizTalk Server $Name $Server'"
        Invoke-CimMethod -InputObject $hostInstance -MethodName Stop -Arguments @{ } | Out-Null
        Write-Verbose "`t '$Name' host instace on '$Server' server has been stopped."
    }
}

<#
.SYNOPSIS
    Returns whether a Microsoft BizTalk Server host instance exists.
.DESCRIPTION
    This command will return $true if the Microsoft BizTalk Server host instance exists.
.PARAMETER Name
    The name of the Microsoft BizTalk Server host.
.PARAMETER Server
    The server on which the Microsoft BizTalk Server host instance is tested for existence; it defaults to the
    local machine name.
.OUTPUTS
    Returns $true if the Microsoft BizTalk Server host instance exists; $false otherwise.
.EXAMPLE
    PS> Test-BizTalkHostInstance -Name 'Transmit Host'
.EXAMPLE
    PS> Test-BizTalkHostInstance -Name 'Transmit Host' -Server 'ComputerName'
.NOTES
    © 2020 be.stateless.
#>
function Test-BizTalkHostInstance {
    [CmdletBinding()]
    [OutputType([bool])]
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
    [bool] (Get-CimInstance -Namespace root/MicrosoftBizTalkServer -Class MSBTS_HostInstance -Filter "Name='Microsoft BizTalk Server $Name $Server'")
}
