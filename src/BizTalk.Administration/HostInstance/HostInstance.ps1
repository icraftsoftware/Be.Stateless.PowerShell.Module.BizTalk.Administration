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

<#
.SYNOPSIS
   Asserts the existence of a Microsoft BizTalk Server Host Instance and whether it is in the expected state.
.DESCRIPTION
   This command will throw if the Microsoft BizTalk Server Host Instance does not exist, or is not in the expected
   state, and will silently complete otherwise.
.PARAMETER Name
   The name of the Microsoft BizTalk Server Host.
.PARAMETER Server
   The server on which the Microsoft BizTalk Server Host Instance is tested for existence.
.PARAMETER HostInstance
   The Microsoft BizTalk Server Host Instance to disable.
.PARAMETER IsDisabled
   Whether the Microsoft BizTalk Server Host Instance must be disabled from starting as well.
.PARAMETER IsStarted
   Whether the Microsoft BizTalk Server Host Instance must be started as well.
.PARAMETER IsStopped
   Whether the Microsoft BizTalk Server Host Instance must be stopped as well.
.OUTPUTS
   Throws if the Microsoft BizTalk Server Host Instance does not exist or is not in the expected state; completes
   silently otherwise.
.EXAMPLE
   PS> Assert-BizTalkHostInstance -IsStarted -InformationAction Continue -HostInstance @(Get-BizTalkHostInstance)
.EXAMPLE
   PS> Get-BizTalkHostInstance | Assert-BizTalkHostInstance -IsStarted
.EXAMPLE
   PS> Assert-BizTalkHostInstance -Name TransmitHost, ReceiveHost
.EXAMPLE
   PS> Assert-BizTalkHostInstance -Name TransmitHost -IsStarted
.EXAMPLE
   PS> Assert-BizTalkHostInstance -Name TransmitHost -IsDisabled -IsStopped
.EXAMPLE
   PS> Assert-BizTalkHostInstance -Name TransmitHost -Server 'ComputerName'
.NOTES
   © 2022 be.stateless.
#>
function Assert-BizTalkHostInstance {
   [CmdletBinding(DefaultParameterSetName = 'by-filter')]
   [OutputType([void])]
   param(
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter-started')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter-stopped')]
      [ArgumentCompleter( { Get-BizTalkHost | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Name,

      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter-started')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter-stopped')]
      [ArgumentCompleter( { Get-BizTalkServer | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Server,

      [Parameter(Mandatory = $true, ParameterSetName = 'by-object', ValueFromPipeline = $true)]
      [Parameter(Mandatory = $true, ParameterSetName = 'by-object-started', ValueFromPipeline = $true)]
      [Parameter(Mandatory = $true, ParameterSetName = 'by-object-stopped', ValueFromPipeline = $true)]
      [AllowEmptyCollection()]
      [object[]]
      $HostInstance,

      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter-started')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter-stopped')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-object')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-object-started')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-object-stopped')]
      [Switch]
      $IsDisabled,

      [Parameter(Mandatory = $true, ParameterSetName = 'by-filter-started')]
      [Parameter(Mandatory = $true, ParameterSetName = 'by-object-started')]
      [Switch]
      $IsStarted,

      [Parameter(Mandatory = $true, ParameterSetName = 'by-filter-stopped')]
      [Parameter(Mandatory = $true, ParameterSetName = 'by-object-stopped')]
      [Switch]
      $IsStopped
   )
   Begin {
      Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
      if ($PSCmdlet.ParameterSetName -match '^by-filter') { $HostInstance = @(Enumerate-BizTalkHostInstance -Name $Name -Server $Server -UserBoundParameters $PSBoundParameters -ErrorAction Stop -WarningAction SilentlyContinue) }
      $arguments = @{ } + $PSBoundParameters
      $arguments.Remove('Name') | Out-Null
      $arguments.Remove('Server') | Out-Null
   }
   Process {
      $HostInstance | Where-Object -FilterScript { $_ } -PipelineVariable instance | ForEach-Object -Process {
         $arguments.HostInstance = $instance
         if (-not(Test-BizTalkHostInstance @arguments)) { throw ($hostInstanceMessages.Error_State -f $instance.HostName, $instance.RunningServer) }
      }
   }
}

<#
.SYNOPSIS
   Disables a Microsoft BizTalk Server Host Instance.
.DESCRIPTION
   Disables a Microsoft BizTalk Server Host Instance.
.PARAMETER Name
   The name of the Microsoft BizTalk Server Host Instance to disable.
.PARAMETER Server
   The server on which run the Microsoft BizTalk Server Host Instance to disable.
.PARAMETER HostInstance
   The Microsoft BizTalk Server Host Instance to disable.
.EXAMPLE
   PS> Get-BizTalkHostInstance | Disable-BizTalkHostInstance
   Disables all the Microsoft BizTalk Server Host Instances on all the servers.
.EXAMPLE
   PS> Disable-BizTalkHostInstance -HostInstance @(Get-BizTalkHostInstance)
   Disables all the Microsoft BizTalk Server Host Instances on all the servers.
.EXAMPLE
   PS> Disable-BizTalkHostInstance -Name BizTalkServerApplication
   Disables the Microsoft BizTalk Server Host Instance named BizTalkServerApplication on all the servers.
.EXAMPLE
   PS> Disable-BizTalkHostInstance -Name TransmitHost, ReceiveHost
   Disables the Microsoft BizTalk Server Host Instances named TransmitHost and ReceiveHost on all the servers.
.EXAMPLE
   PS> Disable-BizTalkHostInstance -Name TransmitHost, ReceiveHost -Server Aritchaut, Aubergine
   Disables the Microsoft BizTalk Server Host Instances named TransmitHost and ReceiveHost on the servers Aritchaut
   and Aubergine.
.NOTES
   © 2022 be.stateless.
#>
function Disable-BizTalkHostInstance {
   [CmdletBinding(DefaultParameterSetName = 'by-filter', SupportsShouldProcess = $true)]
   [OutputType([void])]
   param(
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [ArgumentCompleter( { Get-BizTalkHost | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Name,

      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [ArgumentCompleter( { Get-BizTalkServer | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Server,

      [Parameter(Mandatory = $true, ParameterSetName = 'by-object', ValueFromPipeline = $true)]
      [AllowEmptyCollection()]
      [object[]]
      $HostInstance
   )
   Begin {
      Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
      if ($PSCmdlet.ParameterSetName -eq 'by-filter') { $HostInstance = @(Enumerate-BizTalkHostInstance -Name $Name -Server $Server -UserBoundParameters $PSBoundParameters -ErrorAction SilentlyContinue -WarningAction Continue) }
   }
   Process {
      $HostInstance | Where-Object -FilterScript { $_ } -PipelineVariable instance | ForEach-Object -Process {
         if ($PsCmdlet.ShouldProcess($globalMessages.Should_Target, ($hostInstanceMessages.Should_Disable -f $instance.HostName, $instance.RunningServer))) {
            Write-Information -MessageData ($hostInstanceMessages.Info_Disabling -f $instance.HostName, $instance.RunningServer)
            $instance.IsDisabled = $true
            Set-CimInstance -ErrorAction Stop -InputObject $instance
            Write-Information -MessageData ($hostInstanceMessages.Info_Disabled -f $instance.HostName, $instance.RunningServer)
         }
      }
   }
}

<#
.SYNOPSIS
   Enables a Microsoft BizTalk Server Host Instance.
.DESCRIPTION
   Enables a Microsoft BizTalk Server Host Instance.
.PARAMETER Name
   The name of the Microsoft BizTalk Server Host Instance to enable.
.PARAMETER Server
   The server on which run the Microsoft BizTalk Server Host Instance to enable.
.PARAMETER HostInstance
   The Microsoft BizTalk Server Host Instance to enable.
.EXAMPLE
   PS> Get-BizTalkHostInstance | Enable-BizTalkHostInstance
   Enables all the Microsoft BizTalk Server Host Instances on all the servers.
.EXAMPLE
   PS> Enable-BizTalkHostInstance -HostInstance @(Get-BizTalkHostInstance)
   Enables all the Microsoft BizTalk Server Host Instances on all the servers.
.EXAMPLE
   PS> Enable-BizTalkHostInstance -Name BizTalkServerApplication
   Enables the Microsoft BizTalk Server Host Instance named BizTalkServerApplication on all the servers.
.EXAMPLE
   PS> Enable-BizTalkHostInstance -Name TransmitHost, ReceiveHost
   Enables the Microsoft BizTalk Server Host Instances named TransmitHost and ReceiveHost on all the servers.
.EXAMPLE
   PS> Enable-BizTalkHostInstance -Name TransmitHost, ReceiveHost -Server Aritchaut, Aubergine
   Enables the Microsoft BizTalk Server Host Instances named TransmitHost and ReceiveHost on the servers Aritchaut
   and Aubergine.
.NOTES
   © 2022 be.stateless.
#>
function Enable-BizTalkHostInstance {
   [CmdletBinding(DefaultParameterSetName = 'by-filter', SupportsShouldProcess = $true)]
   [OutputType([void])]
   param(
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [ArgumentCompleter( { Get-BizTalkHost | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Name,

      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [ArgumentCompleter( { Get-BizTalkServer | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Server,

      [Parameter(Mandatory = $true, ParameterSetName = 'by-object', ValueFromPipeline = $true)]
      [AllowEmptyCollection()]
      [object[]]
      $HostInstance
   )
   Begin {
      Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
      if ($PSCmdlet.ParameterSetName -eq 'by-filter') { $HostInstance = @(Enumerate-BizTalkHostInstance -Name $Name -Server $Server -UserBoundParameters $PSBoundParameters -ErrorAction SilentlyContinue -WarningAction Continue) }
   }
   Process {
      $HostInstance | Where-Object -FilterScript { $_ } -PipelineVariable instance | ForEach-Object -Process {
         if ($PsCmdlet.ShouldProcess($globalMessages.Should_Target, ($hostInstanceMessages.Should_Enable -f $instance.HostName, $instance.RunningServer))) {
            Write-Information -MessageData ($hostInstanceMessages.Info_Enabling -f $instance.HostName, $instance.RunningServer)
            $instance.IsDisabled = $false
            Set-CimInstance -ErrorAction Stop -InputObject $instance
            Write-Information -MessageData ($hostInstanceMessages.Info_Enabled -f $instance.HostName, $instance.RunningServer)
         }
      }
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
   Gets all the Microsoft BizTalk Server Host Instances on all the servers.
.EXAMPLE
   PS> Get-BizTalkHostInstance -Name BizTalkServerApplication
   Gets the Microsoft BizTalk Server Host Instances named BizTalkServerApplication on all the servers.
.EXAMPLE
   PS> Get-BizTalkHostInstance -Name BizTalkServerApplication, BizTalkServerIsolatedHost
   Gets the Microsoft BizTalk Server Host Instances named BizTalkServerApplication and BizTalkServerIsolatedHost on
   all the servers.
.EXAMPLE
   PS> Get-BizTalkHostInstance -Server $Env:COMPUTERNAME
   Gets all the Microsoft BizTalk Server Host Instances on the local computer.
.EXAMPLE
   PS> Get-BizTalkHostInstance -Name BizTalkServerApplication -Server $Env:COMPUTERNAME
   Gets the Microsoft BizTalk Server Host Instances named BizTalkServerApplication on the local computer.
.EXAMPLE
   PS> Get-BizTalkHostInstance -Name BizTalkServerApplication, BizTalkServerIsolatedHost -Server Aritchaut, Aubergine
   Gets the Microsoft BizTalk Server Host Instances named BizTalkServerApplication and BizTalkServerIsolatedHost on
   the servers Aritchaut and Aubergine.
.EXAMPLE
   PS> Get-BizTalkHostInstance -Name BizTalkServerApplication, BizTalkServerIsolatedHost -Server Aritchaut, Aubergine -WarningAction Stop
.NOTES
   © 2022 be.stateless.
#>
function Get-BizTalkHostInstance {
   [CmdletBinding()]
   [OutputType([PSCustomObject[]])]
   param(
      [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
      # see https://vexx32.github.io/2018/11/29/Dynamic-ValidateSet/
      [ArgumentCompleter( { Get-BizTalkHost | Select-Object -ExpandProperty Name } )]
      [AllowEmptyString()]
      [AllowEmptyCollection()]
      [AllowNull()]
      [string[]]
      $Name,

      [Parameter(Mandatory = $false)]
      [ArgumentCompleter( { Get-BizTalkServer | Select-Object -ExpandProperty Name } )]
      [AllowEmptyString()]
      [AllowEmptyCollection()]
      [AllowNull()]
      [string[]]
      $Server
   )
   Begin {
      Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
   }
   Process {
      Enumerate-BizTalkHostInstance -Name $Name -Server $Server -UserBoundParameters $PSBoundParameters -ErrorAction SilentlyContinue -WarningAction SilentlyContinue |
         Where-Object -FilterScript { $_ }
   }

}

<#
.SYNOPSIS
   Creates a new Microsoft BizTalk Server Host Instance.
.DESCRIPTION
   Creates a new Microsoft BizTalk Server Host Instance.
.PARAMETER Name
   The name of the Microsoft BizTalk Server Host Instance.
.PARAMETER Credential
   The credential denoting the Windows account that the host instance to create will use to run.
.PARAMETER Server
   The server on which will run the Microsoft BizTalk Server Host Instance to create; it defaults to the local
   machine name.
.PARAMETER Started
   Whether to start this Microsoft BizTalk Server Host Instance upon creation.
.EXAMPLE
   PS> New-BizTalkHostInstance -Name TransmitHost -Credential (Get-Credential)
.EXAMPLE
   PS> New-BizTalkHostInstance -Name TransmitHost -Credential ([PSCredential]::new('logon', (ConvertTo-SecureString password -AsPlainText -Force))) -Server 'server'
.EXAMPLE
   PS> New-BizTalkHostInstance -Name TransmitHost -Credential (New-Object -TypeName PSCredential -ArgumentList logon, (ConvertTo-SecureString password -AsPlainText -Force)) -Disabled -Started
.EXAMPLE
   PS> New-BizTalkHostInstance -Name TransmitHost -Credential (New-Object PSCredential logon, (ConvertTo-SecureString password -AsPlainText -Force)) -WhatIf
.LINK
   https://docs.microsoft.com/en-us/biztalk/core/technical-reference/mapping-and-installing-host-instances-using-wmi
.LINK
   https://sandroaspbiztalkblog.wordpress.com/2013/09/05/powershell-to-configure-biztalk-server-host-and-host-instances-according-to-some-of-the-best-practices/
.LINK
   https://www.powershellgallery.com/packages/BizTalkServer
.NOTES
   © 2022 be.stateless.
#>
function New-BizTalkHostInstance {
   [CmdletBinding(SupportsShouldProcess = $true)]
   [OutputType([PSCustomObject])]
   param(
      [Parameter(Mandatory = $true)]
      [ArgumentCompleter( { Get-BizTalkHost | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { Test-BizTalkHost -Name $_ } )]
      [string]
      $Name,

      [Parameter(Mandatory = $false)]
      [ArgumentCompleter( { Get-BizTalkServer | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [ValidateScript( { Test-BizTalkServer -Name $_ } )]
      [string]
      $Server = $Env:COMPUTERNAME,

      [Parameter(Mandatory = $true)]
      [ValidateNotNullOrEmpty()]
      [PSCredential]
      $Credential
   )
   DynamicParam {
      if (Test-BizTalkHost -Name $Name -Type InProcess) {
         $paramaterAttribute = New-Object System.Management.Automation.ParameterAttribute
         $paramaterAttribute.Mandatory = $false
         $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
         $attributeCollection.Add($paramaterAttribute)
         $disabledParameter = New-Object System.Management.Automation.RuntimeDefinedParameter('Disabled', [switch], $attributeCollection)
         $startedParameter = New-Object System.Management.Automation.RuntimeDefinedParameter('Started', [switch], $attributeCollection)
         $dynamicParameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
         $dynamicParameters.Add('Disabled', $disabledParameter)
         $dynamicParameters.Add('Started', $startedParameter)
         return $dynamicParameters
      }
   }
   Process {
      Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
      if (Test-BizTalkHostInstance -Name $Name -Server $Server) {
         Write-Information -MessageData ($hostInstanceMessages.Info_Existing -f $Name, $Server)
      } elseif ($PsCmdlet.ShouldProcess($globalMessages.Should_Target, ($hostInstanceMessages.Should_Create -f $Name, $Server))) {
         Assert-Elevated
         try {
            Write-Information -MessageData ($hostInstanceMessages.Info_Creating -f $Name, $Server)
            $serverHostInstanceClass = Get-CimClass -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_ServerHost
            $serverHostInstance = New-CimInstance -ErrorAction Stop -CimClass $serverHostInstanceClass -ClientOnly -Property @{
               ServerName           = $Server
               HostName             = $Name
               MgmtDbNameOverride   = ''
               MgmtDbServerOverride = ''
            }
            Invoke-CimMethod -ErrorAction Stop -InputObject $serverHostInstance -MethodName Map -Arguments @{ } -Confirm:$false | Out-Null

            $hostInstanceClass = Get-CimClass -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance
            $hostInstance = New-CimInstance -ErrorAction Stop -CimClass $hostInstanceClass -ClientOnly -Property @{
               Name                 = "Microsoft BizTalk Server $Name $Server"
               HostName             = $Name
               MgmtDbNameOverride   = ''
               MgmtDbServerOverride = ''
            }

            $arguments = @{ GrantLogOnAsService = $true ; Logon = $Credential.UserName ; Password = $Credential.GetNetworkCredential().Password }
            if (Test-GmsaAccountSupport) { $arguments.IsGmsaAccount = $false }
            Invoke-CimMethod -ErrorAction Stop -InputObject $hostInstance -MethodName Install -Arguments $arguments -Confirm:$false | Out-Null

            if (Test-BizTalkHost -Name $Name -Type InProcess) {
               if ($PSBoundParameters.ContainsKey('Disabled') -and $PSBoundParameters.Disabled) {
                  $hostInstance = Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance -Filter "HostName='$Name' and RunningServer='$Server'"
                  $hostInstance.IsDisabled = [bool]$PSBoundParameters.Disabled
                  Set-CimInstance -ErrorAction Stop -InputObject $hostInstance
               } elseif ($PSBoundParameters.ContainsKey('Started') -and $PSBoundParameters.Started) {
                  Invoke-CimMethod -ErrorAction Stop -InputObject $hostInstance -MethodName Start -Arguments @{ } -Confirm:$false | Out-Null
               } else {
                  Invoke-CimMethod -ErrorAction Stop -InputObject $hostInstance -MethodName Stop -Arguments @{ } -Confirm:$false | Out-Null
               }
            }
            Write-Information -MessageData ($hostInstanceMessages.Info_Created -f $Name, $Server)
            Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance -Filter "HostName='$Name' and RunningServer='$Server'"
         } catch {
            Write-Error -Message ($hostInstanceMessages.Error_Create -f $Name, $Server)
            Remove-BizTalkHostInstance -Name $Name -Server $Server
            throw
         }
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
   The server of the Microsoft BizTalk Server Host Instance to remove.
.PARAMETER HostInstance
   The Microsoft BizTalk Server Host Instance to remove.
.EXAMPLE
   PS> Get-BizTalkHostInstance | Remove-BizTalkHostInstance
   Removes all the Microsoft BizTalk Server Host Instances on all the servers.
.EXAMPLE
   PS> Remove-BizTalkHostInstance -HostInstance @(Get-BizTalkHostInstance)
   Removes all the Microsoft BizTalk Server Host Instances on all the servers.
.EXAMPLE
   PS> Remove-BizTalkHostInstance -Name BizTalkServerApplication
   Removes the Microsoft BizTalk Server Host Instance named BizTalkServerApplication on all the servers.
.EXAMPLE
   PS> Remove-BizTalkHostInstance -Name TransmitHost, ReceiveHost
   Removes the Microsoft BizTalk Server Host Instances named TransmitHost and ReceiveHost on all the servers.
.EXAMPLE
   PS> Remove-BizTalkHostInstance -Name TransmitHost, ReceiveHost -Server Aritchaut, Aubergine
   Removes the Microsoft BizTalk Server Host Instances named TransmitHost and ReceiveHost on the servers Aritchaut
   and Aubergine.
.LINK
   https://docs.microsoft.com/en-us/biztalk/core/technical-reference/uninstalling-and-un-mapping-a-host-instance-using-wmi
.LINK
   https://www.powershellgallery.com/packages/BizTalkServer
.NOTES
   © 2022 be.stateless.
#>
function Remove-BizTalkHostInstance {
   [CmdletBinding(DefaultParameterSetName = 'by-filter', SupportsShouldProcess = $true)]
   [OutputType([void])]
   param(
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [ArgumentCompleter( { Get-BizTalkHost | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Name,

      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [ArgumentCompleter( { Get-BizTalkServer | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Server,

      [Parameter(Mandatory = $true, ParameterSetName = 'by-object', ValueFromPipeline = $true)]
      [AllowEmptyCollection()]
      [object[]]
      $HostInstance
   )
   Begin {
      Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
      if ($PSCmdlet.ParameterSetName -eq 'by-filter') { $HostInstance = @(Enumerate-BizTalkHostInstance -Name $Name -Server $Server -UserBoundParameters $PSBoundParameters -ErrorAction SilentlyContinue -WarningAction Continue) }
   }
   Process {
      $HostInstance | Where-Object -FilterScript { $_ } -PipelineVariable instance | ForEach-Object -Process {
         if ($PsCmdlet.ShouldProcess($globalMessages.Should_Target, ($hostInstanceMessages.Should_Remove -f $instance.HostName, $instance.RunningServer))) {
            try {
               Write-Information -MessageData ($hostInstanceMessages.Info_Removing -f $instance.HostName, $instance.RunningServer)
               # https://docs.microsoft.com/en-us/biztalk/core/technical-reference/msbts-hostinstance-configurationstate-property-wmi
               if ($null -ne $instance -and $instance.ConfigurationState -eq 1) {
                  if (Test-BizTalkHost -Name $($instance.HostName) -Type InProcess) {
                     Invoke-CimMethod -ErrorAction Stop -InputObject $instance -MethodName Stop -Arguments @{ } -Confirm:$false | Out-Null
                  }
                  Invoke-CimMethod -ErrorAction Stop -InputObject $instance -MethodName Uninstall -Arguments @{ } -Confirm:$false | Out-Null
               }
               $serverHostInstance = Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_ServerHost -Filter "HostName='$($instance.HostName)' and ServerName='$($instance.RunningServer)'"
               if ($null -ne $serverHostInstance -and $serverHostInstance.IsMapped) {
                  Invoke-CimMethod -ErrorAction Stop -InputObject $serverHostInstance -MethodName Unmap -Arguments @{ } -Confirm:$false | Out-Null
               }
               Write-Information -MessageData ($hostInstanceMessages.Info_Removed -f $instance.HostName, $instance.RunningServer)
            } catch {
               Write-Error -Message ($hostInstanceMessages.Error_Remove -f $instance.HostName, $instance.RunningServer)
               throw
            }
         }
      }
   }
}

<#
.SYNOPSIS
   Restarts a running Microsoft BizTalk Server Host Instance.
.DESCRIPTION
   Restarts a running Microsoft BizTalk Server Host Instance. Unless the -Force switch is passed, this command has no
   effect if the Microsoft BizTalk Server Host Instance to restart is not already running. In other words, unless the
   -Force switch is passed, this command will never start a Host Instance that is not running.
.PARAMETER Name
   The name of the Microsoft BizTalk Server Host Instance to restart.
.PARAMETER Server
   The server on which runs the Microsoft BizTalk Server Host Instance to restart.
.PARAMETER HostInstance
   The Microsoft BizTalk Server Host Instance to restart.
.PARAMETER Force
   Force a non running Microsoft BizTalk Server Host Instance to start.
.EXAMPLE
   PS> Get-BizTalkHostInstance | Restart-BizTalkHostInstance
   Restarts all the Microsoft BizTalk Server Host Instances on all the servers.
.EXAMPLE
   PS> Restart-BizTalkHostInstance -HostInstance @(Get-BizTalkHostInstance)
   Restarts all the Microsoft BizTalk Server Host Instances on all the servers.
.EXAMPLE
   PS> Restart-BizTalkHostInstance -Name BizTalkServerApplication
   Restarts the Microsoft BizTalk Server Host Instance named BizTalkServerApplication on all the servers.
.EXAMPLE
   PS> Restart-BizTalkHostInstance -Name TransmitHost, ReceiveHost
   Restarts the Microsoft BizTalk Server Host Instances named TransmitHost and ReceiveHost on all the servers.
.EXAMPLE
   PS> Restart-BizTalkHostInstance -Name TransmitHost, ReceiveHost -Server Aritchaut, Aubergine
   Restarts the Microsoft BizTalk Server Host Instances named TransmitHost and ReceiveHost on the servers Aritchaut
   and Aubergine.
.LINK
   https://github.com/BTDF/DeploymentFramework/blob/master/src/btdf/Tools/BuildTasks/BizTalkDeploymentFramework.Tasks/ControlBizTalkHostInstance.cs
.NOTES
   © 2022 be.stateless.
#>
function Restart-BizTalkHostInstance {
   [CmdletBinding(DefaultParameterSetName = 'by-filter', SupportsShouldProcess = $true)]
   [OutputType([void])]
   param(
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [ArgumentCompleter( { Get-BizTalkHost | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Name,

      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [ArgumentCompleter( { Get-BizTalkServer | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Server,

      [Parameter(Mandatory = $true, ParameterSetName = 'by-object', ValueFromPipeline = $true)]
      [AllowEmptyCollection()]
      [object[]]
      $HostInstance,

      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-object')]
      [switch]
      $Force
   )
   Begin {
      Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
      if ($PSCmdlet.ParameterSetName -eq 'by-filter') { $HostInstance = @(Enumerate-BizTalkHostInstance -Name $Name -Server $Server -UserBoundParameters $PSBoundParameters -ErrorAction SilentlyContinue -WarningAction Continue) }
   }
   Process {
      $HostInstance | Where-Object -FilterScript { $_ } -PipelineVariable instance | ForEach-Object -Process {
         if (Test-BizTalkHost -Name $($instance.HostName) -Type Isolated) {
            Write-Warning -Message ($hostInstanceMessages.Warn_Start_Stop_Isolated -f $instance.HostName, $instance.RunningServer)
         } elseif (Test-BizTalkHostInstance -HostInstance $instance -IsDisabled) {
            Write-Warning -Message ($hostInstanceMessages.Warn_Start_Disabled -f $instance.HostName, $instance.RunningServer)
         } elseif ($PsCmdlet.ShouldProcess($globalMessages.Should_Target, ($hostInstanceMessages.Should_Restart -f $instance.HostName, $instance.RunningServer))) {
            # https://docs.microsoft.com/en-us/biztalk/core/technical-reference/msbts-hostinstance-servicestate-property-wmi
            if ($Force -or $instance.ServiceState -in @(2, 4) <# Sart Pending or Running #>) {
               Write-Information -MessageData ($hostInstanceMessages.Info_Restarting -f $instance.HostName, $instance.RunningServer)
               Invoke-CimMethod -ErrorAction Stop -InputObject $instance -MethodName Stop -Arguments @{ } -Confirm:$false | Out-Null
               Invoke-CimMethod -ErrorAction Stop -InputObject $instance -MethodName Start -Arguments @{ } -Confirm:$false | Out-Null
               Write-Information -MessageData ($hostInstanceMessages.Info_Restarted -f $instance.HostName, $instance.RunningServer)
            } else {
               Write-Information -MessageData ($hostInstanceMessages.Info_Restart_Unnecessary -f $instance.HostName, $instance.RunningServer)
            }
         }
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
   The server on which run the Microsoft BizTalk Server Host Instance to start.
.PARAMETER HostInstance
   The Microsoft BizTalk Server Host Instance to disable.
.EXAMPLE
   PS> Get-BizTalkHostInstance | Start-BizTalkHostInstance
   Starts all the Microsoft BizTalk Server Host Instances on all the servers.
.EXAMPLE
   PS> Start-BizTalkHostInstance -HostInstance @(Get-BizTalkHostInstance)
   Starts all the Microsoft BizTalk Server Host Instances on all the servers.
.EXAMPLE
   PS> Start-BizTalkHostInstance -Name BizTalkServerApplication
   Starts the Microsoft BizTalk Server Host Instance named BizTalkServerApplication on all the servers.
.EXAMPLE
   PS> Start-BizTalkHostInstance -Name TransmitHost, ReceiveHost
   Starts the Microsoft BizTalk Server Host Instances named TransmitHost and ReceiveHost on all the servers.
.EXAMPLE
   PS> Start-BizTalkHostInstance -Name TransmitHost, ReceiveHost -Server Aritchaut, Aubergine
   Starts the Microsoft BizTalk Server Host Instances named TransmitHost and ReceiveHost on the servers Aritchaut and
   Aubergine.
.LINK
   https://github.com/BTDF/DeploymentFramework/blob/master/src/btdf/Tools/BuildTasks/BizTalkDeploymentFramework.Tasks/ControlBizTalkHostInstance.cs
.NOTES
   © 2022 be.stateless.
#>
function Start-BizTalkHostInstance {
   [CmdletBinding(DefaultParameterSetName = 'by-filter', SupportsShouldProcess = $true)]
   [OutputType([void])]
   param(
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [ArgumentCompleter( { Get-BizTalkHost | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Name,

      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [ArgumentCompleter( { Get-BizTalkServer | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Server,

      [Parameter(Mandatory = $true, ParameterSetName = 'by-object', ValueFromPipeline = $true)]
      [AllowEmptyCollection()]
      [object[]]
      $HostInstance
   )
   Begin {
      Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
      if ($PSCmdlet.ParameterSetName -eq 'by-filter') { $HostInstance = @(Enumerate-BizTalkHostInstance -Name $Name -Server $Server -UserBoundParameters $PSBoundParameters -ErrorAction SilentlyContinue -WarningAction Continue) }
   }
   Process {
      $HostInstance | Where-Object -FilterScript { $_ } -PipelineVariable instance | ForEach-Object -Process {
         if (Test-BizTalkHost -Name $instance.HostName -Type Isolated) {
            Write-Warning -Message ($hostInstanceMessages.Warn_Start_Stop_Isolated -f $instance.HostName, $instance.RunningServer)
         } elseif (Test-BizTalkHostInstance -HostInstance $instance -IsDisabled) {
            Write-Warning -Message ($hostInstanceMessages.Warn_Start_Disabled -f $instance.HostName, $instance.RunningServer)
         } elseif ($PsCmdlet.ShouldProcess($globalMessages.Should_Target, ($hostInstanceMessages.Should_Start -f $instance.HostName, $instance.RunningServer))) {
            Write-Information -MessageData ($hostInstanceMessages.Info_Starting -f $instance.HostName, $instance.RunningServer)
            Invoke-CimMethod -ErrorAction Stop -InputObject $instance -MethodName Start -Arguments @{ } -Confirm:$false | Out-Null
            Write-Information -MessageData ($hostInstanceMessages.Info_Started -f $instance.HostName, $instance.RunningServer)
         }
      }
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
   The server on which run the Microsoft BizTalk Server Host Instance to stop.
.PARAMETER HostInstance
   The Microsoft BizTalk Server Host Instance to disable.
.EXAMPLE
   PS> Get-BizTalkHostInstance | Stop-BizTalkHostInstance
   Stops all the Microsoft BizTalk Server Host Instances on all the servers.
.EXAMPLE
   PS> Stop-BizTalkHostInstance -HostInstance @(Get-BizTalkHostInstance)
   Stops all the Microsoft BizTalk Server Host Instances on all the servers.
.EXAMPLE
   PS> Stop-BizTalkHostInstance -Name BizTalkServerApplication
   Stops the Microsoft BizTalk Server Host Instance named BizTalkServerApplication on all the servers.
.EXAMPLE
   PS> Stop-BizTalkHostInstance -Name TransmitHost, ReceiveHost
   Stops the Microsoft BizTalk Server Host Instances named TransmitHost and ReceiveHost on all the servers.
.EXAMPLE
   PS> Stop-BizTalkHostInstance -Name TransmitHost, ReceiveHost -Server Aritchaut, Aubergine
   Stops the Microsoft BizTalk Server Host Instances named TransmitHost and ReceiveHost on the servers Aritchaut and
   Aubergine.
.LINK
   https://github.com/BTDF/DeploymentFramework/blob/master/src/btdf/Tools/BuildTasks/BizTalkDeploymentFramework.Tasks/ControlBizTalkHostInstance.cs
.NOTES
   © 2022 be.stateless.
#>
function Stop-BizTalkHostInstance {
   [CmdletBinding(DefaultParameterSetName = 'by-filter', SupportsShouldProcess = $true)]
   [OutputType([void])]
   param(
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [ArgumentCompleter( { Get-BizTalkHost | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Name,

      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [ArgumentCompleter( { Get-BizTalkServer | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Server,

      [Parameter(Mandatory = $true, ParameterSetName = 'by-object', ValueFromPipeline = $true)]
      [AllowEmptyCollection()]
      [object[]]
      $HostInstance
   )
   Begin {
      Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
      if ($PSCmdlet.ParameterSetName -eq 'by-filter') { $HostInstance = @(Enumerate-BizTalkHostInstance -Name $Name -Server $Server -UserBoundParameters $PSBoundParameters -ErrorAction SilentlyContinue -WarningAction Continue) }
   }
   Process {
      $HostInstance | Where-Object -FilterScript { $_ } -PipelineVariable instance | ForEach-Object -Process {
         if (Test-BizTalkHost -Name $instance.HostName -Type Isolated) {
            Write-Warning -Message ($hostInstanceMessages.Warn_Start_Stop_Isolated -f $instance.HostName, $instance.RunningServer)
         } elseif ($PsCmdlet.ShouldProcess($globalMessages.Should_Target, ($hostInstanceMessages.Should_Stop -f $instance.HostName, $instance.RunningServer))) {
            Write-Information -MessageData ($hostInstanceMessages.Info_Stopping -f $instance.HostName, $instance.RunningServer)
            Invoke-CimMethod -ErrorAction Stop -InputObject $instance -MethodName Stop -Arguments @{ } -Confirm:$false | Out-Null
            Write-Information -MessageData ($hostInstanceMessages.Info_Stopped -f $instance.HostName, $instance.RunningServer)
         }
      }
   }
}

<#
.SYNOPSIS
   Returns whether a Microsoft BizTalk Server Host Instance exists and whether it is disabled, started or stopped.
.DESCRIPTION
   This command will return $true if the Microsoft BizTalk Server Host Instance exists; $false otherwise. The
   existence test can be combined with the expected state of the Microsoft BizTalk Server Host Instance, i.e. either
   disabled, started or stopped.
.PARAMETER Name
   The name of the Microsoft BizTalk Server Host.
.PARAMETER Server
   The server on which the Microsoft BizTalk Server Host Instance is tested for existence.
.PARAMETER HostInstance
   The Microsoft BizTalk Server Host Instance to disable.
.PARAMETER IsDisabled
   Whether the Microsoft BizTalk Server Host Instance is disabled.
.PARAMETER IsStarted
   Whether the Microsoft BizTalk Server Host Instance is started.
.PARAMETER IsStopped
   Whether the Microsoft BizTalk Server Host Instance is stopped.
.OUTPUTS
   Returns $true if the Microsoft BizTalk Server Host Instance exists and matches its expected state; $false otherwise.
.EXAMPLE
   PS> Test-BizTalkHostInstance -IsStarted -InformationAction Continue -HostInstance @(Get-BizTalkHostInstance)
.EXAMPLE
   PS> Get-BizTalkHostInstance | Test-BizTalkHostInstance -IsStarted
.EXAMPLE
   PS> Test-BizTalkHostInstance -Name TransmitHost
.EXAMPLE
   PS> Test-BizTalkHostInstance -Name TransmitHost -IsStarted
.EXAMPLE
   PS> Test-BizTalkHostInstance -Name TransmitHost -IsDisabled -IsStarted
.EXAMPLE
   PS> Test-BizTalkHostInstance -Name TransmitHost -IsDisabled -IsStopped
.EXAMPLE
   PS> Test-BizTalkHostInstance -Name TransmitHost -Server 'ComputerName'
.NOTES
   © 2022 be.stateless.
#>
function Test-BizTalkHostInstance {
   [CmdletBinding(DefaultParameterSetName = 'by-filter')]
   [OutputType([bool[]])]
   param(
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter-started')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter-stopped')]
      [ArgumentCompleter( { Get-BizTalkHost | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Name,

      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter-started')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter-stopped')]
      [ArgumentCompleter( { Get-BizTalkServer | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Server,

      [Parameter(Mandatory = $true, ParameterSetName = 'by-object', ValueFromPipeline = $true)]
      [Parameter(Mandatory = $true, ParameterSetName = 'by-object-started', ValueFromPipeline = $true)]
      [Parameter(Mandatory = $true, ParameterSetName = 'by-object-stopped', ValueFromPipeline = $true)]
      [AllowEmptyCollection()]
      [object[]]
      $HostInstance,

      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter-started')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter-stopped')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-object')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-object-started')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-object-stopped')]
      [Switch]
      $IsDisabled,

      [Parameter(Mandatory = $true, ParameterSetName = 'by-filter-started')]
      [Parameter(Mandatory = $true, ParameterSetName = 'by-object-started')]
      [Switch]
      $IsStarted,

      [Parameter(Mandatory = $true, ParameterSetName = 'by-filter-stopped')]
      [Parameter(Mandatory = $true, ParameterSetName = 'by-object-stopped')]
      [Switch]
      $IsStopped
   )
   Begin {
      Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
      if ($PSCmdlet.ParameterSetName -match '^by-filter') { $HostInstance = @(Enumerate-BizTalkHostInstance -Name $Name -Server $Server -UserBoundParameters $PSBoundParameters -ErrorAction SilentlyContinue -WarningAction SilentlyContinue) }
   }
   Process {
      $HostInstance | ForEach-Object -Process { $_ } -PipelineVariable instance | ForEach-Object -Process {
         $doesMatchExpectedDisabledState = -not $PSBoundParameters.ContainsKey('IsDisabled') -or ($instance -and $IsDisabled -eq $instance.IsDisabled)
         switch -regex ($PSCmdlet.ParameterSetName) {
            '^by-(filter|object)$' { $instance -and $doesMatchExpectedDisabledState }
            # https://docs.microsoft.com/en-us/biztalk/core/technical-reference/msbts-hostinstance-servicestate-property-wmi
            '-started$' { $instance -and $doesMatchExpectedDisabledState -and (($IsStarted -and $instance.ServiceState -eq 4) -or (-not $IsStarted -and $instance.ServiceState -ne 4)) }
            '-stopped$' { $instance -and $doesMatchExpectedDisabledState -and (($IsStopped -and $instance.ServiceState -eq 1) -or (-not $IsStopped -and $instance.ServiceState -ne 1)) }
         }
      }
   }
}

function Enumerate-BizTalkHostInstance {
   [Diagnostics.CodeAnalysis.SuppressMessage('PSUseApprovedVerbs', '', Justification = 'Non-public function.')]
   [CmdletBinding()]
   [OutputType([PSCustomObject[]])]
   param(
      [Parameter(Mandatory = $false)]
      [AllowEmptyString()]
      [AllowEmptyCollection()]
      [AllowNull()]
      [string[]]
      $Name,

      [Parameter(Mandatory = $false)]
      [AllowEmptyString()]
      [AllowEmptyCollection()]
      [AllowNull()]
      [string[]]
      $Server,

      [Parameter(Mandatory = $true)]
      [HashTable]
      $UserBoundParameters
   )

   function Enumerate-BizTalkHostInstanceCore {
      [CmdletBinding()]
      [OutputType([PSCustomObject[]])]
      param(
         [Parameter(Mandatory = $false)]
         [AllowEmptyString()]
         [AllowEmptyCollection()]
         [AllowNull()]
         [string[]]
         $Name = '', # default value ensures its pipeline will run

         [Parameter(Mandatory = $false)]
         [AllowEmptyString()]
         [AllowEmptyCollection()]
         [AllowNull()]
         [string[]]
         $Server = '' # default value ensures its pipeline will run
      )
      $Name | ForEach-Object -Process { $_ } -PipelineVariable currentName | ForEach-Object -Process {
         $Server | ForEach-Object -Process { $_ } -PipelineVariable currentServer | ForEach-Object -Process {
            $filter, $message = if (![string]::IsNullOrWhiteSpace($currentName) -and ![string]::IsNullOrWhiteSpace($currentServer)) {
               "HostName='$currentName' and RunningServer='$currentServer'"
               $hostInstanceMessages.Error_Not_Found -f $currentName, $currentServer
            } elseif (![string]::IsNullOrWhiteSpace($currentName)) {
               "HostName='$currentName'"
               $hostInstanceMessages.Error_Not_Found_On_Any_Server -f $currentName
            } elseif (![string]::IsNullOrWhiteSpace($currentServer)) {
               "RunningServer='$currentServer'"
               $hostInstanceMessages.Error_None_Found_On_Server -f $currentServer
            } else {
               $null
               $hostInstanceMessages.Error_None_Found
            }
            $instance = Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance -Filter $filter
            if ($null -eq $instance) {
               Write-Error -Message $message
               Write-Warning -Message $message
               $null
            } else {
               $instance
            }
         }
      }
   }

   $arguments = @{ } + $PSBoundParameters
   $arguments.Remove('UserBoundParameters') | Out-Null
   if ($UserBoundParameters.ContainsKey('ErrorAction')) { $arguments.ErrorAction = $UserBoundParameters.ErrorAction }
   if ($UserBoundParameters.ContainsKey('WarningAction')) { $arguments.WarningAction = $UserBoundParameters.WarningAction }
   Enumerate-BizTalkHostInstanceCore @arguments
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

Import-LocalizedData -BindingVariable hostInstanceMessages -FileName HostInstance.Messages.psd1
