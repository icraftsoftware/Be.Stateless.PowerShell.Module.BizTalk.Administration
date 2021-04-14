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

Describe 'Enable-BizTalkHostInstance' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHostInstance -Name Test_Host -Credential (New-Object -TypeName pscredential -ArgumentList '.\BTS_USER', (ConvertTo-SecureString p@ssw0rd -AsPlainText -Force)) -Disabled
    }
    InModuleScope BizTalk.Administration {

        Context 'When Microsoft BizTalk Server Host Instance exists.' {
            It 'Enables the host instance to start when not already enabled.' {
                Mock -CommandName Write-Information
                Test-BizTalkHostInstance -Name Test_Host -IsDisabled | Should -BeTrue
                Enable-BizTalkHostInstance -Name Test_Host
                Test-BizTalkHostInstance -Name Test_Host -IsDisabled | Should -BeFalse
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -eq ($hostInstanceMessages.Info_Enabling -f 'Test_Host', $env:COMPUTERNAME) }
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -eq ($hostInstanceMessages.Info_Enabled -f 'Test_Host', $env:COMPUTERNAME) }
            }
            It 'Enables the host instance to start even when already enabled.' {
                Test-BizTalkHostInstance -Name Test_Host -IsDisabled | Should -BeFalse
                Enable-BizTalkHostInstance -Name Test_Host
                Test-BizTalkHostInstance -Name Test_Host -IsDisabled | Should -BeFalse
            }
        }

        Context 'When Microsoft BizTalk Server Host Instance does not exist.' {
            It 'Skips enabling the host instance.' {
                Mock -CommandName Write-Warning
                Test-BizTalkHostInstance -Name Test_Host_2 | Should -BeFalse
                { Enable-BizTalkHostInstance -Name Test_Host_2 } | Should -Not -Throw
                Should -Invoke -CommandName Write-Warning -ParameterFilter { $Message -eq ($hostInstanceMessages.Error_Not_Found_On_Any_Server -f 'Test_Host_2') }
            }
        }

        Context 'Enabling BizTalk Server Host Instances from the pipeline' {
            It 'Enables hosts.' {
                { 'Test_Host', 'Test_Host_2' | Get-BizTalkHostInstance | Enable-BizTalkHostInstance } | Should -Not -Throw
            }
        }

    }
    AfterAll {
        Remove-BizTalkHost -Name Test_Host
    }

}