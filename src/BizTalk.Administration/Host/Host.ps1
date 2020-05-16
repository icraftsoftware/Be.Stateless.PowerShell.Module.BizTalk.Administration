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

enum HostType {
   InProcess = [Microsoft.BizTalk.ExplorerOM.HostType]::InProcess
   Isolated = [Microsoft.BizTalk.ExplorerOM.HostType]::Isolated
}

<#
.SYNOPSIS
   Asserts the existence of a Microsoft BizTalk Server Host of a given type.
.DESCRIPTION
   This command will throw if the Microsoft BizTalk Server Host does not exist and will silently complete otherwise.
   The asserted check can be narrowed down to a particular Type of Microsoft BizTalk Server Host, i.e. either
   InProcess or Isolated.
.PARAMETER Name
   The name of the Microsoft BizTalk Server Host.
.PARAMETER BizTalkHost
   The Microsoft BizTalk Server Host object.
.PARAMETER Type
   The type of the Microsoft BizTalk Server Host.
.EXAMPLE
   PS> Get-BizTalkHost | Assert-BizTalkHost -Type Isolated
.EXAMPLE
   PS> Assert-BizTalkHost -Host @(Get-BizTalkHost) -Type Isolated
.EXAMPLE
   PS> Assert-BizTalkHost -Name 'Transmit Host'
.EXAMPLE
   PS> Assert-BizTalkHost -Name 'Transmit Host' -Verbose
.NOTES
   © 2022 be.stateless.
#>
function Assert-BizTalkHost {
   [CmdletBinding(DefaultParameterSetName = 'by-filter')]
   [OutputType([void])]
   param(
      [Parameter(Mandatory = $true, ParameterSetName = 'by-filter')]
      [ArgumentCompleter( { Get-BizTalkHost | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Name,

      [Parameter(Mandatory = $true, ParameterSetName = 'by-object', ValueFromPipeline = $true)]
      [Alias('Host')]
      [AllowEmptyCollection()]
      [object[]]
      $BizTalkHost,

      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-object')]
      [HostType]
      $Type
   )
   Begin {
      Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
      if ($PSCmdlet.ParameterSetName -eq 'by-filter') { $BizTalkHost = @(Enumerate-BizTalkHost -Name $Name -UserBoundParameters $PSBoundParameters -ErrorAction Stop -WarningAction SilentlyContinue) }
      $arguments = @{ }
      if ($PSBoundParameters.ContainsKey('Type')) { $arguments.Type = $Type }
   }
   Process {
      $BizTalkHost | Where-Object -FilterScript { $_ } -PipelineVariable currentHost | ForEach-Object -Process {
         $arguments.BizTalkHost = $currentHost
         if (-not(Test-BizTalkHost @arguments)) { throw ($hostMessages.Error_Type -f $currentHost.Name) }
      }
   }
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
   PS> Get-BizTalkHost | Where-Object { $_ | Test-BizTalkHost -Type InProcess }
.EXAMPLE
   PS> Get-BizTalkHost -Type InProcess
.EXAMPLE
   PS> Get-BizTalkHost -Name 'Transmit Host'
.EXAMPLE
   PS> Get-BizTalkHost -Name 'Transmit Host' -Detailed
.NOTES
   © 2022 be.stateless.
#>
function Get-BizTalkHost {
   [CmdletBinding()]
   [OutputType([PSCustomObject[]])]
   param(
      [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true)]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Name,

      [Parameter(Mandatory = $false)]
      [switch]
      $Detailed,

      [Parameter(Mandatory = $false)]
      [HostType]
      $Type
   )
   Begin {
      Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
   }
   Process {
      Enumerate-BizTalkHost -Name $Name -Detailed:$Detailed -UserBoundParameters $PSBoundParameters -ErrorAction SilentlyContinue -WarningAction SilentlyContinue |
         Where-Object -FilterScript { [bool]$_ -and (-not $PSBoundParameters.ContainsKey('Type') -or $_.HostType -eq $Type) }
   }
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
   © 2022 be.stateless.
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
   if (Test-BizTalkHost -Name $Name -Type $Type) {
      Write-Information -MessageData ($hostMessages.Info_Existing -f $Type, $Name)
   } elseif (Test-BizTalkHost -Name $Name) {
      Write-Warning -Message ($hostMessages.Warn_Existing_Different_Type -f $Name)
   } elseif ($PsCmdlet.ShouldProcess($globalMessages.Should_Target, ($hostMessages.Should_Create -f $Type, $Name))) {
      Write-Information -MessageData ($hostMessages.Info_Creating -f $Type, $Name)
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
      Write-Information -MessageData ($hostMessages.Info_Created -f $Type, $Name)
   }
}

<#
.SYNOPSIS
   Removes a Microsoft BizTalk Server Host.
.DESCRIPTION
   Removes a Microsoft BizTalk Server Host.
.PARAMETER Name
   The name of the Microsoft BizTalk Server Host.
.PARAMETER BizTalkHost
   The Microsoft BizTalk Server Host object.
.EXAMPLE
   PS> Get-BizTalkHost | Remove-BizTalkHost
.EXAMPLE
   PS> Remove-BizTalkHost -Host @(Get-BizTalkHost)
.EXAMPLE
   PS> Remove-BizTalkHost -Name 'Transmit Host'
.NOTES
   © 2022 be.stateless.
#>
function Remove-BizTalkHost {
   [CmdletBinding(DefaultParameterSetName = 'by-filter', SupportsShouldProcess = $true)]
   [OutputType([void])]
   param(
      [Parameter(Mandatory = $true, ParameterSetName = 'by-filter')]
      [ArgumentCompleter( { Get-BizTalkHost | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Name,

      [Parameter(Mandatory = $true, ParameterSetName = 'by-object', ValueFromPipeline = $true)]
      [Alias('Host')]
      [AllowEmptyCollection()]
      [object[]]
      $BizTalkHost
   )
   Begin {
      Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
      if ($PSCmdlet.ParameterSetName -eq 'by-filter') { $BizTalkHost = @(Enumerate-BizTalkHost -Name $Name -UserBoundParameters $PSBoundParameters -ErrorAction SilentlyContinue -WarningAction Continue) }
   }
   Process {
      $BizTalkHost | Where-Object -FilterScript { $_ } -PipelineVariable currentHost | ForEach-Object -Process {
         if ($PsCmdlet.ShouldProcess($globalMessages.Should_Target, ($hostMessages.Should_Remove -f $currentHost.Name))) {
            Write-Information -MessageData ($hostMessages.Info_Removing -f $currentHost.Name)
            Remove-CimInstance -ErrorAction Stop -InputObject $currentHost
            Write-Information -MessageData ($hostMessages.Info_Removed -f $currentHost.Name)
         }
      }
   }
}

<#
.SYNOPSIS
   Returns whether a Microsoft BizTalk Server Host of a given type exists.
.DESCRIPTION
   This command will return $true if the Microsoft BizTalk Server Host exists; $false otherwise. The existence test
   can be narrowed down to a particular Type of Microsoft BizTalk Server Host, i.e. either InProcess or Isolated.
.PARAMETER Name
   The name of the Microsoft BizTalk Server Host.
.PARAMETER BizTalkHost
   The Microsoft BizTalk Server Host object.
.PARAMETER Type
   The type of the Microsoft BizTalk Server Host.
.OUTPUTS
   $true if the Microsoft BizTalk Server Host exists and is of the given Type; $false otherwise.
.EXAMPLE
   PS> Get-BizTalkHost | Test-BizTalkHost -Type Isolated
.EXAMPLE
   PS> Test-BizTalkHost -Host @(Get-BizTalkHost) -Type Isolated
.EXAMPLE
   PS> Test-BizTalkHost -Name 'Transmit Host'
.EXAMPLE
   PS> Test-BizTalkHost -Name 'Transmit Host' -Type Isolated
.NOTES
   © 2022 be.stateless.
#>
function Test-BizTalkHost {
   [CmdletBinding(DefaultParameterSetName = 'by-filter')]
   [OutputType([bool[]])]
   param(
      [Parameter(Mandatory = $true, ParameterSetName = 'by-filter')]
      [ArgumentCompleter( { Get-BizTalkHost | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Name,

      [Parameter(Mandatory = $true, ParameterSetName = 'by-object', ValueFromPipeline = $true)]
      [Alias('Host')]
      [AllowEmptyCollection()]
      [object[]]
      $BizTalkHost,

      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-object')]
      [HostType]
      $Type
   )
   Begin {
      Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
      if ($PSCmdlet.ParameterSetName -eq 'by-filter') { $BizTalkHost = @(Enumerate-BizTalkHost -Name $Name -UserBoundParameters $PSBoundParameters -ErrorAction SilentlyContinue -WarningAction SilentlyContinue) }
   }
   Process {
      $BizTalkHost | ForEach-Object -Process { $_ } -PipelineVariable currentHost | ForEach-Object -Process {
         [bool]$currentHost -and (-not $PSBoundParameters.ContainsKey('Type') -or $currentHost.HostType -eq $Type)
      }
   }
}

<#
.SYNOPSIS
   Updates the configuration settings of a Microsoft BizTalk Server Host.
.DESCRIPTION
   Updates the configuration settings of a Microsoft BizTalk Server Host.
.PARAMETER Name
   The name of the Microsoft BizTalk Server Host.
.PARAMETER BizTalkHost
   The Microsoft BizTalk Server Host object.
.PARAMETER x86
   Whether instances of this host will be 32-bit only processes.
.PARAMETER Default
   Whether this host is to be the default host in the Microsoft BizTalk Server group or not.
.PARAMETER Tracking
   Wheter to enable the Microsoft BizTalk Server Tracking component for this host or not.
.PARAMETER Trusted
   Whether Microsoft BizTalk Server should trust this host or not.
.EXAMPLE
   PS> Get-BizTalkHost | Update-BizTalkHost -x86
.EXAMPLE
   PS> Update-BizTalkHost -Host @(Get-BizTalkHost) -x86
.EXAMPLE
   PS> Update-BizTalkHost -Name 'Transmit Host' -x86 -Verbose
   With the -Verbose switch, this command will confirm this process is 32 bit.
.EXAMPLE
   PS> Update-BizTalkHost -Name 'Transmit Host' -x86 -Verbose -WhatIf
.EXAMPLE
   PS> Update-BizTalkHost -Name 'Transmit Host' -x86:$false -Verbose
   With the -Verbose switch, this command will confirm this process is not 32 bit.
.NOTES
   © 2022 be.stateless.
#>
function Update-BizTalkHost {
   [CmdletBinding(DefaultParameterSetName = 'by-filter', SupportsShouldProcess = $true)]
   [OutputType([void])]
   param(
      [Parameter(Mandatory = $true, ParameterSetName = 'by-filter')]
      [ArgumentCompleter( { Get-BizTalkHost | Select-Object -ExpandProperty Name } )]
      [ValidateNotNullOrEmpty()]
      [string[]]
      $Name,

      [Parameter(Mandatory = $true, ParameterSetName = 'by-object', ValueFromPipeline = $true)]
      [Alias('Host')]
      [AllowEmptyCollection()]
      [object[]]
      $BizTalkHost,

      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-object')]
      [switch]
      $x86,

      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-object')]
      [switch]
      $Default,

      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-object')]
      [switch]
      $Tracking,

      [Parameter(Mandatory = $false, ParameterSetName = 'by-filter')]
      [Parameter(Mandatory = $false, ParameterSetName = 'by-object')]
      [switch]
      $Trusted
   )
   Begin {
      Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
      if ($PSCmdlet.ParameterSetName -eq 'by-filter') { $BizTalkHost = @(Enumerate-BizTalkHost -Name $Name -Detailed -UserBoundParameters $PSBoundParameters -ErrorAction SilentlyContinue -WarningAction Continue) }
   }
   Process {
      function Set-BizTalkHostProperty {
         [CmdletBinding(SupportsShouldProcess = $true)]
         [OutputType([void])]
         param(
            [Parameter(Mandatory = $true)]
            [object]
            $BizTalkHost,

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
         if ($BizTalkHost.$Property -ne $value -and $PsCmdlet.ShouldProcess($globalMessages.Should_Target, $ActionToPerform)) {
            Write-Information -MessageData "`t $ActionToPerform..."
            $BizTalkHost.$Property = $Value
            Set-CimInstance -ErrorAction Stop -InputObject $BizTalkHost
            Write-Information -MessageData "`t $PerformedAction."
         }
      }

      $BizTalkHost | Where-Object -FilterScript { $_ } -PipelineVariable currentHost | ForEach-Object -Process {
         if (Get-Member -InputObject $currentHost -Name IsHost32BitOnly -ErrorAction Ignore | Test-None) { $currentHost = Get-BizTalkHost -Name $currentHost.Name -Detailed }
         if ($x86.IsPresent) {
            $subject = "'$($currentHost.Name)' host's 32-bit only restriction"
            Set-BizTalkHostProperty -BizTalkHost $currentHost -Property IsHost32BitOnly -Value $x86 `
               -ActionToPerform ('{1} {0}' -f $Subject, (@('Enabling', 'Disabling')[!$x86])) `
               -PerformedAction ('{0} has been {1}' -f $Subject, (@('enabled', 'disabled')[!$x86]))
         }

         if ($Default.IsPresent -and -not $currentHost.IsDefault) {
            Set-BizTalkHostProperty -BizTalkHost $currentHost -Property IsDefault -Value $Default `
               -ActionToPerform "Defining '$($currentHost.Name)' host as default Microsoft BizTalk Server Group host" `
               -PerformedAction "'$($currentHost.Name)' host has been defined as default Microsoft BizTalk Server Group host"
         }

         if ($Tracking.IsPresent) {
            $subject = "'$($currentHost.Name)' host's Tracking capability"
            Set-BizTalkHostProperty -BizTalkHost $currentHost -Property HostTracking -Value $Tracking `
               -ActionToPerform ('{1} {0}' -f $Subject, (@('Enabling', 'Disabling')[!$Tracking])) `
               -PerformedAction ('{0} has been {1}' -f $Subject, (@('enabled', 'disabled')[!$Tracking]))
         }

         if ($Trusted.IsPresent) {
            $subject = "'$($currentHost.Name)' host's Trusted Authentication"
            Set-BizTalkHostProperty -BizTalkHost $currentHost -Property AuthTrusted -Value $Trusted `
               -ActionToPerform ('{1} {0}' -f $Subject, (@('Enabling', 'Disabling')[!$Trusted])) `
               -PerformedAction ('{0} has been {1}' -f $Subject, (@('enabled', 'disabled')[!$Trusted]))
         }
      }
   }
}

function Enumerate-BizTalkHost {
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
      [switch]
      $Detailed,

      [Parameter(Mandatory = $true)]
      [HashTable]
      $UserBoundParameters
   )
   function Enumerate-BizTalkHostCore {
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
         [switch]
         $Detailed
      )
      $className = if ($Detailed) { 'MSBTS_HostSetting' } else { 'MSBTS_Host' }
      $Name | ForEach-Object -Process { $_ } -PipelineVariable currentName | ForEach-Object -Process {
         $filter, $message = if (![string]::IsNullOrWhiteSpace($Name)) {
            "Name='$currentName'"
            $hostMessages.Error_Not_Found -f $currentName
         } else {
            $null
            $hostMessages.Error_None_Found
         }
         $instance = Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName $className -Filter $filter
         if ($null -eq $instance) {
            Write-Error -Message $message
            Write-Warning -Message $message
            $null
         } else {
            $instance
         }
      }
   }
   $arguments = @{ } + $PSBoundParameters
   $arguments.Remove('UserBoundParameters') | Out-Null
   if ($UserBoundParameters.ContainsKey('ErrorAction')) { $arguments.ErrorAction = $UserBoundParameters.ErrorAction }
   if ($UserBoundParameters.ContainsKey('WarningAction')) { $arguments.WarningAction = $UserBoundParameters.WarningAction }
   Enumerate-BizTalkHostCore @arguments
}

Import-LocalizedData -BindingVariable hostMessages -FileName Host.Messages.psd1
