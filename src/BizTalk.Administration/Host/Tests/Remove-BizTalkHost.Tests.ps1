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

Describe 'Remove-BizTalkHost' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host_1 -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHost -Name Test_Host_2 -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHost -Name Test_Host_3 -Type InProcess -Group 'BizTalk Application Users'
    }
    InModuleScope BizTalk.Administration {

        Context 'When BizTalk Server Host already exists' {
            It 'Removes the BizTalk Server Host.' {
                Mock -CommandName Write-Information
                Test-BizTalkHost -Name Test_Host_1 | Should -BeTrue
                { Remove-BizTalkHost -Name Test_Host_1 } | Should -Not -Throw
                Test-BizTalkHost -Name Test_Host_1 | Should -BeFalse
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -eq ($hostMessages.Info_Removing -f 'Test_Host_1') }
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -eq ($hostMessages.Info_Removed -f 'Test_Host_1') }
            }
        }

        Context 'When BizTalk Server Host does not exist' {
            It 'Skips BizTalk Server Host removal.' {
                Mock -CommandName Write-Warning
                Test-BizTalkHost -Name Test_Host_1 | Should -BeFalse
                { Remove-BizTalkHost -Name Test_Host_1 } | Should -Not -Throw
                Should -Invoke -CommandName Write-Warning -ParameterFilter { $Message -eq ($hostMessages.Error_Not_Found -f 'Test_Host_1') }
            }
        }

        Context 'Removing BizTalk Server Hosts from the pipeline' {
            It 'Removes the BizTalk Server Hosts.' {
                { 'Test_Host_2', 'Test_Host_3' | Get-BizTalkHost | Remove-BizTalkHost } | Should -Not -Throw
            }
        }


    }
    AfterAll {
        Remove-BizTalkHost -Name Test_Host_3 -WarningAction SilentlyContinue
        Remove-BizTalkHost -Name Test_Host_2 -WarningAction SilentlyContinue
        Remove-BizTalkHost -Name Test_Host_1 -WarningAction SilentlyContinue
    }
}