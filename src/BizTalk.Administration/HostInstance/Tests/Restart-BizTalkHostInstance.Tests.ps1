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

Import-Module -Name $PSScriptRoot\..\..\BizTalk.Administration.psd1 -Force

Describe 'Restart-BizTalkHostInstance' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHostInstance -Name Test_Host -Credential (New-Object -TypeName pscredential -ArgumentList '.\BTS_USER', (ConvertTo-SecureString p@ssw0rd -AsPlainText -Force))
    }
    InModuleScope BizTalk.Administration {

        Context 'When the host instance exists' {
            It 'Does not start a host instance which is stopped.' {
                Mock -CommandName Write-Information
                # https://docs.microsoft.com/en-us/biztalk/core/technical-reference/msbts-hostinstance-servicestate-property-wmi
                Test-BizTalkHostInstance -Name Test_Host -IsStopped | Should -BeTrue
                { Restart-BizTalkHostInstance -Name Test_Host } | Should -Not -Throw
                Test-BizTalkHostInstance -Name Test_Host -IsStopped | Should -BeTrue
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -eq ($hostInstanceMessages.Info_Restart_Unnecessary -f 'Test_Host', $env:COMPUTERNAME) }
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
                $pid1 | Should -Not -Be $pid0 # process id has changed due to a host instance's service restart
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -eq ($hostInstanceMessages.Info_Restarting -f 'Test_Host', $env:COMPUTERNAME) }
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -eq ($hostInstanceMessages.Info_Restarted -f 'Test_Host', $env:COMPUTERNAME) }
            }
            It 'Skips restarting an Isolated host instance.' {
                Mock -CommandName Write-Warning
                Test-BizTalkHostInstance -Name BizTalkServerIsolatedHost | Should -BeTrue
                { Restart-BizTalkHostInstance -Name BizTalkServerIsolatedHost -InformationAction Continue } | Should -Not -Throw
                Should -Invoke -CommandName Write-Warning -ParameterFilter { $Message -eq ($hostInstanceMessages.Warn_Start_Stop_Isolated -f 'BizTalkServerIsolatedHost', $env:COMPUTERNAME) }
            }
        }

        Context 'When the host instance does not exist' {
            It 'Skips restarting the host instance.' {
                Mock -CommandName Write-Warning
                Test-BizTalkHostInstance -Name Test_Host_3 | Should -BeFalse
                { Restart-BizTalkHostInstance -Name Test_Host_3 } | Should -Not -Throw
                Should -Invoke -CommandName Write-Warning -ParameterFilter { $Message -eq ($hostInstanceMessages.Error_Not_Found_On_Any_Server -f 'Test_Host_3') }
            }
        }

        Context 'Restarting BizTalk Server Host Instances from the pipeline' {
            It 'Restarts hosts.' {
                { 'Test_Host', 'Test_Host_2' | Get-BizTalkHostInstance | Restart-BizTalkHostInstance } | Should -Not -Throw
            }
        }

    }
    AfterAll {
        Stop-BizTalkHostInstance -Name Test_Host
        Remove-BizTalkHost -Name Test_Host
    }
}