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

Describe 'Start-BizTalkHostInstance' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host_1 -Type Isolated -Group 'BizTalk Isolated Host Users'
        New-BizTalkHostInstance -Name Test_Host_1 -User BTS_USER -Password 'p@ssw0rd'
        New-BizTalkHost -Name Test_Host_2 -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHostInstance -Name Test_Host_2 -User BTS_USER -Password 'p@ssw0rd'
    }
    InModuleScope BizTalk.Administration {

        Context 'When the host instance exists' {
            It 'Starts the host instance.' {
                Mock -CommandName Write-Information
                Test-BizTalkHostInstance -Name Test_Host_2 -IsStopped | Should -BeTrue
                { Start-BizTalkHostInstance -Name Test_Host_2 } | Should -Not -Throw
                Test-BizTalkHostInstance -Name Test_Host_2 -IsStarted | Should -BeTrue
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match "Microsoft BizTalk Server 'Test_Host_2' Host Instance on '$($env:COMPUTERNAME)' server is being started\.\.\." }
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match "Microsoft BizTalk Server 'Test_Host_2' Host Instance on '$($env:COMPUTERNAME)' server has been started\." }
            }
            It 'Starts the host instance irrelevantly of whether it is already started.' {
                Test-BizTalkHostInstance -Name Test_Host_2 -IsStarted | Should -BeTrue
                { Start-BizTalkHostInstance -Name Test_Host_2 } | Should -Not -Throw
                Test-BizTalkHostInstance -Name Test_Host_2 -IsStarted | Should -BeTrue
            }
            It 'Skips starting an Isolated host instance.' {
                Mock -CommandName Write-Information
                Test-BizTalkHostInstance -Name Test_Host_1 | Should -BeTrue
                { Start-BizTalkHostInstance -Name Test_Host_1 -InformationAction Continue } | Should -Not -Throw
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match "Microsoft BizTalk Server 'Test_Host_1' Host Instance on '$($env:COMPUTERNAME)' server is an Isolated Host and can neither be started nor stopped\." }
            }
        }

        Context 'When the host instance does not exist' {
            It 'Skips starting the host instance.' {
                Mock -CommandName Write-Information
                Test-BizTalkHostInstance -Name Test_Host_3 | Should -BeFalse
                { Start-BizTalkHostInstance -Name Test_Host_3 -InformationAction Continue } | Should -Not -Throw
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match "Microsoft BizTalk Server 'Test_Host_3' Host Instance on '$($env:COMPUTERNAME)' server does not exist\." }
            }
        }

    }
    AfterAll {
        Stop-BizTalkHostInstance -Name Test_Host_2
        Remove-BizTalkHost -Name Test_Host_2
        Remove-BizTalkHost -Name Test_Host_1
    }
}