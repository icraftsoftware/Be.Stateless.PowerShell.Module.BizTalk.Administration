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

using assembly Microsoft.BizTalk.ExplorerOM

Import-Module -Name $PSScriptRoot\..\Host -Force

Describe 'New-BizTalkHost' {
    InModuleScope Host {

        Context 'When BizTalk Server Host does not yet exist' {
            Mock -CommandName Write-Information -ModuleName Host
            It 'Creates a new BizTalk Server Host.' {
                Test-BizTalkHost -Name Test_Host | Should -BeFalse
                { New-BizTalkHost -Name Test_Host -Type InProcess -Group 'BizTalk Application Users' -InformationAction Continue } | Should -Not -Throw
                Test-BizTalkHost -Name Test_Host | Should -BeTrue
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName Host -ParameterFilter { $MessageData -match 'InProcess ''Test_Host'' host has been created.' }
            }
        }

        Context 'When BizTalk Server Host already exists' {
            Mock -CommandName Write-Information -ModuleName Host
            It 'Skips BizTalk Server Host creation.' {
                Test-BizTalkHost -Name BizTalkServerApplication | Should -BeTrue
                { New-BizTalkHost -Name BizTalkServerApplication -Type InProcess -Group 'BizTalk Application Users' -InformationAction Continue } | Should -Not -Throw
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName Host -ParameterFilter { $MessageData -match 'InProcess ''BizTalkServerApplication'' host already exists.' }
            }
        }

    }
    AfterAll {
        Remove-BizTalkHost -Name Test_Host
    }
}