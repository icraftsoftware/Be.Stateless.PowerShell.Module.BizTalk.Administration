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

Describe 'Remove-BizTalkHost' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host -Type InProcess -Group 'BizTalk Application Users'
    }
    InModuleScope Host {

        Context 'When BizTalk Server Host already exists' {
            It 'Removes the BizTalk Server Host.' {
                Mock -CommandName Write-Information
                Test-BizTalkHost -Name Test_Host | Should -BeTrue
                { Remove-BizTalkHost -Name Test_Host -InformationAction Continue } | Should -Not -Throw
                Test-BizTalkHost -Name Test_Host | Should -BeFalse
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match 'Removing Microsoft BizTalk Server ''Test_Host'' host\.\.\.' }
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match 'Microsoft BizTalk Server ''Test_Host'' host has been removed\.' }
            }
        }

        Context 'When BizTalk Server Host does not exist' {
            It 'Skips BizTalk Server Host removal.' {
                Mock -CommandName Write-Information
                Test-BizTalkHost -Name Test_Host | Should -BeFalse
                { Remove-BizTalkHost -Name Test_Host -InformationAction Continue } | Should -Not -Throw
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match 'Microsoft BizTalk Server ''Test_Host'' host has already been removed\.' }
            }
        }

    }
    AfterAll {
        Remove-BizTalkHost -Name Test_Host
    }
}