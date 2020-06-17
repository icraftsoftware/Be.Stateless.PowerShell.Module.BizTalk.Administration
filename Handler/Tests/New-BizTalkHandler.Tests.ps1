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

Describe 'New-BizTalkHandler' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host -Type InProcess -Group 'BizTalk Application Users'
    }
    InModuleScope Handler {

        Context 'When BizTalk Server Handler does not yet exist' {
            It 'Creates a new BizTalk Server Handler.' {
                Mock -CommandName Write-Information
                Test-BizTalkHandler -Adapter FILE -Host Test_Host -Direction Send | Should -BeFalse
                { New-BizTalkHandler -Adapter FILE -Host Test_Host -Direction Send -InformationAction Continue } | Should -Not -Throw
                Test-BizTalkHandler -Adapter FILE -Host Test_Host -Direction Send | Should -BeTrue
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match 'Creating Microsoft BizTalk Server Send ''FILE'' handler for ''Test_Host'' host\.\.\.' }
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match 'Microsoft BizTalk Server Send ''FILE'' handler for ''Test_Host'' host has been created\.' }
            }
        }

        Context 'When BizTalk Server Handler already exists' {
            It 'Skips the BizTalk Server Handler creation.' {
                Mock -CommandName Write-Information
                Test-BizTalkHandler -Adapter FILE -Host Test_Host -Direction Send | Should -BeTrue
                { New-BizTalkHandler -Adapter FILE -Host Test_Host -Direction Send -InformationAction Continue } | Should -Not -Throw
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match 'Microsoft BizTalk Server Send ''FILE'' handler for ''Test_Host'' host has already been created\.' }
            }
        }

    }
    AfterAll {
        Remove-BizTalkHandler -Adapter FILE -Host Test_Host -Direction Send
        Remove-BizTalkHost -Name Test_Host
    }
}
