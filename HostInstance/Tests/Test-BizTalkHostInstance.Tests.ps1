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

Describe 'Test-BizTalkHostInstance' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host_1 -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHostInstance -Name Test_Host_1 -User BTS_USER -Password 'p@ssw0rd' -Disabled
    }
    InModuleScope HostInstance {

        Context 'Testing the existence of BizTalk Server Host Instances' {
            It 'Returns $true when the host instance exists.' {
                Test-BizTalkHostInstance -Name BizTalkServerIsolatedHost | Should -BeTrue
            }
            It 'Returns $true when the host instance exists and is disabled.' {
                Test-BizTalkHostInstance -Name Test_Host_1 -IsDisabled | Should -BeTrue
            }
            It 'Returns $true when the host instance exists, is stopped, and is disabled.' {
                Test-BizTalkHostInstance -Name Test_Host_1 -IsDisabled -IsStopped | Should -BeTrue
            }
            It 'Returns $true when the host instance exists and is started.' {
                Test-BizTalkHostInstance -Name BizTalkServerApplication -IsStarted | Should -BeTrue
            }
            It 'Returns $false when the host instance exists, is started but is not disabled.' {
                Test-BizTalkHostInstance -Name BizTalkServerApplication -IsDisabled -IsStarted | Should -BeFalse
            }
            It 'Returns $false when the host instance exists and is not stopped.' {
                Test-BizTalkHostInstance -Name BizTalkServerApplication -IsStopped | Should -BeFalse
            }
            It 'Returns $false when the host instance does not exist.' {
                Test-BizTalkHostInstance -Name Inexistent-Host | Should -BeFalse
            }
        }

    }
    AfterAll {
        Remove-BizTalkHost -Name Test_Host_1
    }
}