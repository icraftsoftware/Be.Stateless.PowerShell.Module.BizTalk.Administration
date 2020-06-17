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

Describe 'Disable-BizTalkHostInstance' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHostInstance -Name Test_Host -User BTS_USER -Password 'p@ssw0rd'
    }
    InModuleScope HostInstance {

        Context 'When Microsoft BizTalk Server Host Instance exists.' {
            It 'Disables the host instance from starting when not already disabled.' {
                Test-BizTalkHostInstance -Name Test_Host -IsDisabled | Should -BeFalse
                Disable-BizTalkHostInstance -Name Test_Host
                Test-BizTalkHostInstance -Name Test_Host -IsDisabled | Should -BeTrue
            }
            It 'Disables the host instance from starting even when already disabled.' {
                Test-BizTalkHostInstance -Name Test_Host -IsDisabled | Should -BeTrue
                Disable-BizTalkHostInstance -Name Test_Host
                Test-BizTalkHostInstance -Name Test_Host -IsDisabled | Should -BeTrue
            }
        }

        Context 'When Microsoft BizTalk Server Host Instance does not exist.' {
            It 'Skips disabling the host instance.' {
                Mock -CommandName Write-Information
                Test-BizTalkHostInstance -Name Test_Host_2 | Should -BeFalse
                { Disable-BizTalkHostInstance -Name Test_Host_2 -InformationAction Continue } | Should -Not -Throw
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match "'Test_Host_2' Host Instance on '$($env:COMPUTERNAME)' server does not exist." }
            }
        }

    }
    AfterAll {
        Remove-BizTalkHost -Name Test_Host
    }
}