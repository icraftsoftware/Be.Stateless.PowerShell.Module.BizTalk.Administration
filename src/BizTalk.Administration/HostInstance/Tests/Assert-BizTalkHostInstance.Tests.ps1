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

Describe 'Assert-BizTalkHostInstance' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host_1 -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHostInstance -Name Test_Host_1 -Credential (New-Object -TypeName pscredential -ArgumentList BTS_USER, (ConvertTo-SecureString p@ssw0rd -AsPlainText -Force)) -Disabled
    }
    InModuleScope BizTalk.Administration {

        Context 'When the BizTalk Server Host Instance does not exist' {
            It 'Throws.' {
                { Assert-BizTalkHostInstance -Name Inexistent_Host } | Should -Throw -ExpectedMessage ($hostInstanceMessages.Error_Not_Found_On_Any_Server -f 'Inexistent_Host')
            }
        }

        Context 'When the BizTalk Server Host Instance exists' {
            It 'Does not throw.' {
                { Assert-BizTalkHostInstance -Name BizTalkServerIsolatedHost } | Should  -Not -Throw
            }
        }

        Context 'When the BizTalk Server Host Instance is started and not disabled' {
            It 'Does not throw when the host instance is not disabled.' {
                { Assert-BizTalkHostInstance -Name BizTalkServerApplication -IsDisabled:$false } | Should  -Not -Throw
            }
            It 'Throws when the host instance should be disabled.' {
                { Assert-BizTalkHostInstance -Name BizTalkServerApplication -IsDisabled } | Should -Throw -ExpectedMessage ($hostInstanceMessages.Error_State -f 'BizTalkServerApplication', $Env:COMPUTERNAME)
            }
            It 'Does not throw when the host instance is started.' {
                { Assert-BizTalkHostInstance -Name BizTalkServerApplication -IsStarted } | Should  -Not -Throw
            }
            It 'Throws when the host instance should not be started.' {
                { Assert-BizTalkHostInstance -Name BizTalkServerApplication -IsStarted:$false } | Should -Throw -ExpectedMessage ($hostInstanceMessages.Error_State -f 'BizTalkServerApplication', $Env:COMPUTERNAME)
            }
            It 'Does not throw when the host instance is not disabled and is started.' {
                { Assert-BizTalkHostInstance -Name BizTalkServerApplication -IsDisabled:$false -IsStarted } | Should  -Not -Throw
            }
            It 'Throws when the host instance is started but should be disabled.' {
                { Assert-BizTalkHostInstance -Name BizTalkServerApplication -IsDisabled -IsStarted } | Should -Throw -ExpectedMessage ($hostInstanceMessages.Error_State -f 'BizTalkServerApplication', $Env:COMPUTERNAME)
            }
            It 'Throws when the host instance is not disabled but should not be started.' {
                { Assert-BizTalkHostInstance -Name BizTalkServerApplication -IsDisabled:$false -IsStarted:$false } | Should -Throw -ExpectedMessage ($hostInstanceMessages.Error_State -f 'BizTalkServerApplication', $Env:COMPUTERNAME)
            }
            It 'Does not throw when the host instance is not stopped.' {
                { Assert-BizTalkHostInstance -Name BizTalkServerApplication -IsStopped:$false } | Should  -Not -Throw
            }
            It 'Throws when the host instance should be stopped.' {
                { Assert-BizTalkHostInstance -Name BizTalkServerApplication -IsStopped } | Should -Throw -ExpectedMessage ($hostInstanceMessages.Error_State -f 'BizTalkServerApplication', $Env:COMPUTERNAME)
            }
        }

        Context 'When the BizTalk Server Host Instance is stopped and disabled' {
            It 'Does not throw when the host instance is disabled.' {
                { Assert-BizTalkHostInstance -Name Test_Host_1 -IsDisabled } | Should  -Not -Throw
            }
            It 'Throws when the host instance should not be disabled.' {
                { Assert-BizTalkHostInstance -Name Test_Host_1 -IsDisabled:$false } | Should -Throw -ExpectedMessage ($hostInstanceMessages.Error_State -f 'Test_Host_1', $Env:COMPUTERNAME)
            }
            It 'Does not throw when the host instance is not started.' {
                { Assert-BizTalkHostInstance -Name Test_Host_1 -IsStarted:$false } | Should  -Not -Throw
            }
            It 'Throws when the host instance should be started.' {
                { Assert-BizTalkHostInstance -Name Test_Host_1 -IsStarted } | Should -Throw -ExpectedMessage ($hostInstanceMessages.Error_State -f 'Test_Host_1', $Env:COMPUTERNAME)
            }
            It 'Does not throw when the host instance is stopped.' {
                { Assert-BizTalkHostInstance -Name Test_Host_1 -IsStopped } | Should  -Not -Throw
            }
            It 'Throws when the host instance should not be stopped.' {
                { Assert-BizTalkHostInstance -Name Test_Host_1 -IsStopped:$false } | Should -Throw -ExpectedMessage ($hostInstanceMessages.Error_State -f 'Test_Host_1', $Env:COMPUTERNAME)
            }
            It 'Does not throw when the host instance is disabled and is stopped.' {
                { Assert-BizTalkHostInstance -Name Test_Host_1 -IsDisabled -IsStopped } | Should  -Not -Throw
            }
            It 'Throws when the host instance is stopped but should be disabled.' {
                { Assert-BizTalkHostInstance -Name Test_Host_1 -IsDisabled:$false -IsStopped } | Should -Throw -ExpectedMessage ($hostInstanceMessages.Error_State -f 'Test_Host_1', $Env:COMPUTERNAME)
            }
            It 'Throws when the host instance is disabled but should not be stopped.' {
                { Assert-BizTalkHostInstance -Name Test_Host_1 -IsDisabled -IsStopped:$false } | Should -Throw -ExpectedMessage ($hostInstanceMessages.Error_State -f 'Test_Host_1', $Env:COMPUTERNAME)
            }
        }

        Context 'Asserting BizTalk Server Host Instances from the pipeline' {
            It 'Throws when the host instance is not in the expected state.' {
                { 'BizTalkServerApplication', 'BizTalkServerIsolatedHost' | Get-BizTalkHostInstance | Assert-BizTalkHostInstance -IsStarted } | Should -Throw -ExpectedMessage ($hostInstanceMessages.Error_State -f 'BizTalkServerIsolatedHost', $Env:COMPUTERNAME)
            }
        }

    }
    AfterAll {
        Remove-BizTalkHost -Name Test_Host_1
    }
}