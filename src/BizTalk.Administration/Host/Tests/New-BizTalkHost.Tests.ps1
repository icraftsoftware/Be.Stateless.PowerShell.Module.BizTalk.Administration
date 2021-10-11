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

Describe 'New-BizTalkHost' {
    InModuleScope BizTalk.Administration {

        Context 'When BizTalk Server Host does not yet exist' {
            It 'Creates a new BizTalk Server Host.' {
                Mock -CommandName Write-Information
                Test-BizTalkHost -Name Test_Host | Should -BeFalse
                { New-BizTalkHost -Name Test_Host -Type InProcess -Group 'BizTalk Application Users' -InformationAction Continue } | Should -Not -Throw
                Test-BizTalkHost -Name Test_Host | Should -BeTrue
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -eq ($hostMessages.Info_Creating -f 'InProcess', 'Test_Host') }
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -eq ($hostMessages.Info_Created -f 'InProcess', 'Test_Host') }
            }
        }

        Context 'When BizTalk Server Host already exists' {
            It 'Skips and informs BizTalk Server Host creation of the same type.' {
                Mock -CommandName Write-Information
                Test-BizTalkHost -Name BizTalkServerApplication | Should -BeTrue
                { New-BizTalkHost -Name BizTalkServerApplication -Type InProcess -Group 'BizTalk Application Users' -InformationAction Continue } | Should -Not -Throw
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -eq ($hostMessages.Info_Existing -f 'InProcess', 'BizTalkServerApplication') }
            }
            It 'Skips and warns BizTalk Server Host creation of a different type.' {
                Mock -CommandName Write-Warning
                Test-BizTalkHost -Name BizTalkServerApplication | Should -BeTrue
                { New-BizTalkHost -Name BizTalkServerApplication -Type Isolated -Group 'BizTalk Application Users' -InformationAction Continue } | Should -Not -Throw
                Should -Invoke -CommandName Write-Warning -ParameterFilter { $Message -eq ($hostMessages.Warn_Existing_Different_Type -f 'BizTalkServerApplication') }
            }
        }

    }
    AfterAll {
        Remove-BizTalkHost -Name Test_Host
    }
}