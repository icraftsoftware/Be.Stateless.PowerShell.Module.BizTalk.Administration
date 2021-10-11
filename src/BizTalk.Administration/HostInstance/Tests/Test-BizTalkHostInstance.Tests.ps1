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

Describe 'Test-BizTalkHostInstance' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host_1 -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHostInstance -Name Test_Host_1 -Credential (New-Object -TypeName PSCredential -ArgumentList '.\BTS_USER', (ConvertTo-SecureString p@ssw0rd -AsPlainText -Force)) -Disabled
    }
    InModuleScope BizTalk.Administration {

        Context 'When the BizTalk Server Host Instance does not exist' {
            It 'Returns $false.' {
                Test-BizTalkHostInstance -Name Inexistent-Host | Should -BeFalse
            }
        }

        Context 'When the BizTalk Server Host Instance exists' {
            It 'Returns $true.' {
                Test-BizTalkHostInstance -Name BizTalkServerIsolatedHost | Should -BeTrue
            }
        }

        Context 'When the BizTalk Server Host Instance is started and not disabled' {
            It 'Returns $true when the host instance is not disabled.' {
                Test-BizTalkHostInstance -Name BizTalkServerApplication -IsDisabled:$false | Should -BeTrue
            }
            It 'Returns $false when the host instance should be disabled.' {
                Test-BizTalkHostInstance -Name BizTalkServerApplication -IsDisabled | Should -BeFalse
            }
            It 'Returns $true when the host instance is started.' {
                Test-BizTalkHostInstance -Name BizTalkServerApplication -IsStarted | Should -BeTrue
            }
            It 'Returns $false when the host instance should not be started.' {
                Test-BizTalkHostInstance -Name BizTalkServerApplication -IsStarted:$false | Should -BeFalse
            }
            It 'Returns $true when the host instance is not disabled and is started.' {
                Test-BizTalkHostInstance -Name BizTalkServerApplication -IsDisabled:$false -IsStarted | Should -BeTrue
            }
            It 'Returns $false when the host instance is started but should be disabled.' {
                Test-BizTalkHostInstance -Name BizTalkServerApplication -IsDisabled -IsStarted | Should -BeFalse
            }
            It 'Returns $false when the host instance is not disabled but should not be started.' {
                Test-BizTalkHostInstance -Name BizTalkServerApplication -IsDisabled:$false -IsStarted:$false | Should -BeFalse
            }
            It 'Returns $true when the host instance is not stopped.' {
                Test-BizTalkHostInstance -Name BizTalkServerApplication -IsStopped:$false | Should -BeTrue
            }
            It 'Returns $false when the host instance should be stopped.' {
                Test-BizTalkHostInstance -Name BizTalkServerApplication -IsStopped | Should -BeFalse
            }
        }

        Context 'When the BizTalk Server Host Instance is stopped and disabled' {
            It 'Returns $true when the host instance is disabled.' {
                Test-BizTalkHostInstance -Name Test_Host_1 -IsDisabled | Should -BeTrue
            }
            It 'Returns $false when the host instance should not be disabled.' {
                Test-BizTalkHostInstance -Name Test_Host_1 -IsDisabled:$false | Should -BeFalse
            }
            It 'Returns $true when the host instance is not started.' {
                Test-BizTalkHostInstance -Name Test_Host_1 -IsStarted:$false | Should -BeTrue
            }
            It 'Returns $false when the host instance should be started.' {
                Test-BizTalkHostInstance -Name Test_Host_1 -IsStarted | Should -BeFalse
            }
            It 'Returns $true when the host instance is stopped.' {
                Test-BizTalkHostInstance -Name Test_Host_1 -IsStopped | Should -BeTrue
            }
            It 'Returns $false when the host instance should not be stopped.' {
                Test-BizTalkHostInstance -Name Test_Host_1 -IsStopped:$false | Should -BeFalse
            }
            It 'Returns $true when the host instance is disabled and is stopped.' {
                Test-BizTalkHostInstance -Name Test_Host_1 -IsDisabled -IsStopped | Should -BeTrue
            }
            It 'Returns $false when the host instance is stopped but should be disabled.' {
                Test-BizTalkHostInstance -Name Test_Host_1 -IsDisabled:$false -IsStopped | Should -BeFalse
            }
            It 'Returns $false when the host instance is disabled but should not be stopped.' {
                Test-BizTalkHostInstance -Name Test_Host_1 -IsDisabled -IsStopped:$false | Should -BeFalse
            }
        }

        Context 'Testing BizTalk Server Host Instances from the pipeline' {
            It 'Returns test results.' {
                'BizTalkServerApplication', 'BizTalkServerIsolatedHost' | Get-BizTalkHostInstance | Test-BizTalkHostInstance -IsStarted | Should -Be $true, $false
            }
        }

    }
    AfterAll {
        Remove-BizTalkHost -Name Test_Host_1
    }
}