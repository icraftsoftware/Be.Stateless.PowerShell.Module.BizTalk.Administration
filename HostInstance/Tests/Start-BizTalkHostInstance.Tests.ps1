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

Describe 'Start-BizTalkHostInstance' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host_1 -Type Isolated -Group 'BizTalk Isolated Host Users'
        New-BizTalkHostInstance -Name Test_Host_1 -User BTS_USER -Password 'p@ssw0rd'
        New-BizTalkHost -Name Test_Host_2 -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHostInstance -Name Test_Host_2 -User BTS_USER -Password 'p@ssw0rd'
    }
    InModuleScope HostInstance {

        Context 'When the host instance exists' {
            Mock -CommandName Write-Information -ModuleName HostInstance
            It 'Starts the host instance.' {
                Test-BizTalkHostInstance -Name Test_Host_2 | Should -BeTrue
                # https://docs.microsoft.com/en-us/biztalk/core/technical-reference/msbts-hostinstance-servicestate-property-wmi
                Get-BizTalkHostInstance Test_Host_2 | Select-Object -ExpandProperty ServiceState | Should -Be 1
                { Start-BizTalkHostInstance -Name Test_Host_2 } | Should -Not -Throw
                Get-BizTalkHostInstance Test_Host_2 | Select-Object -ExpandProperty ServiceState | Should -Be 4
            }
            It 'Starts the host instance irrelevantly of whether it is already started.' {
                Test-BizTalkHostInstance -Name Test_Host_2 | Should -BeTrue
                Get-BizTalkHostInstance Test_Host_2 | Select-Object -ExpandProperty ServiceState | Should -Be 4
                { Start-BizTalkHostInstance -Name Test_Host_2 } | Should -Not -Throw
                Get-BizTalkHostInstance Test_Host_2 | Select-Object -ExpandProperty ServiceState | Should -Be 4
            }
            It 'Skips starting an Isolated host instance.' {
                Test-BizTalkHostInstance -Name Test_Host_1 | Should -BeTrue
                { Start-BizTalkHostInstance -Name Test_Host_1 -InformationAction Continue } | Should -Not -Throw
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName HostInstance -ParameterFilter { $MessageData -match "'Test_Host_1' Host Instance on '$($env:COMPUTERNAME)' server is an Isolated Host and cannot be started." }
            }
        }

        Context 'When the host instance does not exist' {
            Mock -CommandName Write-Information -ModuleName HostInstance
            It 'Skips starting the host instance.' {
                Test-BizTalkHostInstance -Name Test_Host_3 | Should -BeFalse
                { Start-BizTalkHostInstance -Name Test_Host_3 -InformationAction Continue } | Should -Not -Throw
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName HostInstance -ParameterFilter { $MessageData -match "'Test_Host_3' Host Instance on '$($env:COMPUTERNAME)' server does not exist." }
            }
        }

    }
    AfterAll {
        Stop-BizTalkHostInstance -Name Test_Host_2
        Remove-BizTalkHost -Name Test_Host_2
        Remove-BizTalkHost -Name Test_Host_1
    }
}