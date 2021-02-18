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

Describe 'Remove-BizTalkHandler' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHandler -Adapter FILE -Host Test_Host -Direction Send
    }
    InModuleScope BizTalk.Administration {

        Context 'When BizTalk Server Handler exists' {
            It 'Removes the BizTalk Server Handler.' {
                Mock -CommandName Write-Information
                Test-BizTalkHandler -Adapter FILE -Host Test_Host -Direction Send | Should -BeTrue
                { Remove-BizTalkHandler -Adapter FILE -Host Test_Host -Direction Send -InformationAction Continue } | Should -Not -Throw
                Test-BizTalkHandler -Adapter FILE -Host Test_Host -Direction Send | Should -BeFalse
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match 'Removing Microsoft BizTalk Server Send ''FILE'' handler for ''Test_Host'' host\.\.\.' }
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match 'Microsoft BizTalk Server Send ''FILE'' handler for ''Test_Host'' host has been removed\.' }
            }
        }

        Context 'When BizTalk Server Handler does not exist' {
            It 'Skips the BizTalk Server Handler removal.' {
                Mock -CommandName Write-Information
                Test-BizTalkHandler -Adapter FILE -Host Test_Host -Direction Send | Should -BeFalse
                { Remove-BizTalkHandler -Adapter FILE -Host Test_Host -Direction Send -InformationAction Continue } | Should -Not -Throw
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match 'Microsoft BizTalk Server Send ''FILE'' handler for ''Test_Host'' host has already been removed\.' }
            }
        }

    }
    AfterAll {
        Remove-BizTalkHost -Name Test_Host
    }
}
