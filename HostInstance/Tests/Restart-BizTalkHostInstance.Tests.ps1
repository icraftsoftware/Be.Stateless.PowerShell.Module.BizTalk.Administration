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
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#endregion

Import-Module -Name $PSScriptRoot\..\HostInstance -Force

Describe 'Restart-BizTalkHostInstance' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHostInstance -Name Test_Host -User BTS_USER -Password 'p@ssw0rd'
    }
    InModuleScope HostInstance {

        Context 'When the host instance exists' {
            It 'Does not start a host instance which is stopped.' {
                Mock -CommandName Write-Information
                # https://docs.microsoft.com/en-us/biztalk/core/technical-reference/msbts-hostinstance-servicestate-property-wmi
                Test-BizTalkHostInstance -Name Test_Host -IsStopped | Should -BeTrue
                { Restart-BizTalkHostInstance -Name Test_Host } | Should -Not -Throw
                Test-BizTalkHostInstance -Name Test_Host -IsStopped | Should -BeTrue
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match "Microsoft BizTalk Server 'Test_Host' Host Instance on '$($env:COMPUTERNAME)' server does not need to be restarted as it is not running\." }
            }
            It 'Forces a stopped host instance to start.' {
                Test-BizTalkHostInstance -Name Test_Host -IsStopped | Should -BeTrue
                { Restart-BizTalkHostInstance -Name Test_Host -Force } | Should -Not -Throw
                Test-BizTalkHostInstance -Name Test_Host -IsStarted | Should -BeTrue
            }
            It 'Restarts a started host instance.' {
                Mock -CommandName Write-Information
                Test-BizTalkHostInstance -Name Test_Host -IsStarted | Should -BeTrue
                $pid0 = Get-CimInstance -ClassName Win32_Service -Filter "Name='BTSSvc`$Test_Host'" | Select-Object -ExpandProperty ProcessId
                { Restart-BizTalkHostInstance -Name Test_Host } | Should -Not -Throw
                Test-BizTalkHostInstance -Name Test_Host -IsStarted | Should -BeTrue
                $pid1 = Get-CimInstance -ClassName Win32_Service -Filter "Name='BTSSvc`$Test_Host'" | Select-Object -ExpandProperty ProcessId
                $pid1 | Should -Not -Be $pid0 # process id has changed due to a host intance's service restart
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match "Microsoft BizTalk Server 'Test_Host' Host Instance on '$($env:COMPUTERNAME)' server is being restarted\.\.\." }
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match "Microsoft BizTalk Server 'Test_Host' Host Instance on '$($env:COMPUTERNAME)' server has been restarted\." }
            }
            It 'Skips restarting an Isolated host instance.' {
                Mock -CommandName Write-Information
                Test-BizTalkHostInstance -Name BizTalkServerIsolatedHost | Should -BeTrue
                { Restart-BizTalkHostInstance -Name BizTalkServerIsolatedHost -InformationAction Continue } | Should -Not -Throw
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match "Microsoft BizTalk Server 'BizTalkServerIsolatedHost' Host Instance on '$($env:COMPUTERNAME)' server is an Isolated Host and can neither be started nor stopped\." }
            }
        }

        Context 'When the host instance does not exist' {
            It 'Skips restarting the host instance.' {
                Mock -CommandName Write-Information
                Test-BizTalkHostInstance -Name Test_Host_3 | Should -BeFalse
                { Restart-BizTalkHostInstance -Name Test_Host_3 -InformationAction Continue } | Should -Not -Throw
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match "Microsoft BizTalk Server 'Test_Host_3' Host Instance on '$($env:COMPUTERNAME)' server does not exist\." }
            }
        }

    }
    AfterAll {
        Stop-BizTalkHostInstance -Name Test_Host
        Remove-BizTalkHost -Name Test_Host
    }
}