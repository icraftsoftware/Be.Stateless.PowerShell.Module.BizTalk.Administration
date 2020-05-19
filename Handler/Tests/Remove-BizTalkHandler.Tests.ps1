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

Import-Module -Name $PSScriptRoot\..\Handler -Force

Describe 'Remove-BizTalkHandler' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHandler -Adapter FILE -Host Test_Host -Direction Send
    }
    InModuleScope Handler {

        Context 'When BizTalk Server Handler exists' {
            Mock -CommandName Write-Information -ModuleName Handler
            It 'Removes the BizTalk Server Handler.' {
                Test-BizTalkHandler -Adapter FILE -Host Test_Host -Direction Send | Should -BeTrue
                { Remove-BizTalkHandler -Adapter FILE -Host Test_Host -Direction Send -InformationAction Continue } | Should -Not -Throw
                Test-BizTalkHandler -Adapter FILE -Host Test_Host -Direction Send | Should -BeFalse
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName Handler -ParameterFilter { $MessageData -match 'Send FILE handler for ''Test_Host'' host has been removed.' }
            }
        }

        Context 'When BizTalk Server Handler does not exist' {
            Mock -CommandName Write-Information -ModuleName Handler
            It 'Skips the BizTalk Server Handler creation.' {
                Test-BizTalkHandler -Adapter FILE -Host Test_Host -Direction Send | Should -BeFalse
                { Remove-BizTalkHandler -Adapter FILE -Host Test_Host -Direction Send -InformationAction Continue } | Should -Not -Throw
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName Handler -ParameterFilter { $MessageData -match 'Send FILE handler for ''Test_Host'' host does not exist.' }
            }
        }

    }
    AfterAll {
        Remove-BizTalkHost -Name Test_Host
    }
}