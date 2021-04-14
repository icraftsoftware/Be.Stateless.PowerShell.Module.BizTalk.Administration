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

Describe 'Disable-BizTalkHostInstance' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHostInstance -Name Test_Host -Credential (New-Object -TypeName pscredential -ArgumentList '.\BTS_USER', (ConvertTo-SecureString p@ssw0rd -AsPlainText -Force))
    }
    InModuleScope BizTalk.Administration {

        Context 'When Microsoft BizTalk Server Host Instance exists.' {
            It 'Disables the host instance from starting when not already disabled.' {
                Mock -CommandName Write-Information
                Test-BizTalkHostInstance -Name Test_Host -IsDisabled | Should -BeFalse
                Disable-BizTalkHostInstance -Name Test_Host
                Test-BizTalkHostInstance -Name Test_Host -IsDisabled | Should -BeTrue
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -eq ($hostInstanceMessages.Info_Disabling -f 'Test_Host', $env:COMPUTERNAME) }
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -eq ($hostInstanceMessages.Info_Disabled -f 'Test_Host', $env:COMPUTERNAME) }
            }
            It 'Disables the host instance from starting even when already disabled.' {
                Test-BizTalkHostInstance -Name Test_Host -IsDisabled | Should -BeTrue
                Disable-BizTalkHostInstance -Name Test_Host
                Test-BizTalkHostInstance -Name Test_Host -IsDisabled | Should -BeTrue
            }
        }

        Context 'When Microsoft BizTalk Server Host Instance does not exist.' {
            It 'Skips disabling the host instance.' {
                Mock -CommandName Write-Warning
                Test-BizTalkHostInstance -Name Test_Host_2 | Should -BeFalse
                { Disable-BizTalkHostInstance -Name Test_Host_2 } | Should -Not -Throw
                Should -Invoke -CommandName Write-Warning -ParameterFilter { $Message -eq ($hostInstanceMessages.Error_Not_Found_On_Any_Server -f 'Test_Host_2') }
            }
        }

        Context 'Disabling BizTalk Server Host Instances from the pipeline' {
            It 'Disables hosts.' {
                { 'Test_Host', 'Test_Host_2' | Get-BizTalkHostInstance | Disable-BizTalkHostInstance } | Should -Not -Throw
            }
        }
    }
    AfterAll {
        Remove-BizTalkHost -Name Test_Host
    }
}