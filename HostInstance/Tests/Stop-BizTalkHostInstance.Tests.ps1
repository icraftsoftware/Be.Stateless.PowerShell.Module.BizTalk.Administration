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

Import-Module -Name $PSScriptRoot\..\..\BizTalk.Administration.psm1 -Force

Describe 'Stop-BizTalkHostInstance' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host_1 -Type Isolated -Group 'BizTalk Isolated Host Users'
        New-BizTalkHostInstance -Name Test_Host_1 -User BTS_USER -Password 'p@ssw0rd'
        New-BizTalkHost -Name Test_Host_2 -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHostInstance -Name Test_Host_2 -User BTS_USER -Password 'p@ssw0rd' -Started
    }
    InModuleScope BizTalk.Administration {

        Context 'When the host instance exists' {
            It 'Stops the host instance.' {
                Mock -CommandName Write-Information
                Test-BizTalkHostInstance -Name Test_Host_2 -IsStarted | Should -BeTrue
                { Stop-BizTalkHostInstance -Name Test_Host_2 } | Should -Not -Throw
                Test-BizTalkHostInstance -Name Test_Host_2 -IsStopped | Should -BeTrue
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match "Microsoft BizTalk Server 'Test_Host_2' Host Instance on '$($env:COMPUTERNAME)' server is being stopped\.\.\." }
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match "Microsoft BizTalk Server 'Test_Host_2' Host Instance on '$($env:COMPUTERNAME)' server has been stopped\." }
            }
            It 'Stops the host instance irrelevantly of whether it is already stopped.' {
                Test-BizTalkHostInstance -Name Test_Host_2 -IsStopped | Should -BeTrue
                { Stop-BizTalkHostInstance -Name Test_Host_2 } | Should -Not -Throw
                Test-BizTalkHostInstance -Name Test_Host_2 -IsStopped | Should -BeTrue
            }
            It 'Skips starting an Isolated host instance.' {
                Mock -CommandName Write-Information
                Test-BizTalkHostInstance -Name Test_Host_1 | Should -BeTrue
                { Stop-BizTalkHostInstance -Name Test_Host_1 -InformationAction Continue } | Should -Not -Throw
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match "Microsoft BizTalk Server 'Test_Host_1' Host Instance on '$($env:COMPUTERNAME)' server is an Isolated Host and can neither be started nor stopped\." }
            }
        }

        Context 'When the host instance does not exist' {
            It 'Skips starting the host instance.' {
                Mock -CommandName Write-Information
                Test-BizTalkHostInstance -Name Test_Host_3 | Should -BeFalse
                { Stop-BizTalkHostInstance -Name Test_Host_3 -InformationAction Continue } | Should -Not -Throw
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match "'Test_Host_3' Host Instance on '$($env:COMPUTERNAME)' server does not exist." }
            }
        }

    }
    AfterAll {
        Remove-BizTalkHost -Name Test_Host_2
        Remove-BizTalkHost -Name Test_Host_1
    }
}