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

Import-Module -Name $PSScriptRoot\..\Application -Force

Describe 'Remove-BizTalkApplication' {
    InModuleScope Application {

        Context 'Removing Microsoft BizTalk Server Applications' {
            It 'Skips application removal when it does not exist.' {
                Mock -CommandName Write-Information
                { Remove-BizTalkApplication -Name 'Dummy.BizTalk.Application' -InformationAction Continue } | Should -Not -Throw
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match 'Microsoft BizTalk Server Application ''Dummy.BizTalk.Application'' has already been removed\.$' }
            }
            It 'Removes an application by name when it exists.' {
                Mock -CommandName Write-Information
                New-BizTalkApplication -Name 'Dummy.BizTalk.Application'
                { Remove-BizTalkApplication -Name 'Dummy.BizTalk.Application' -InformationAction Continue } | Should -Not -Throw
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match 'Removing Microsoft BizTalk Server Application ''Dummy.BizTalk.Application''\.\.\.$' }
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match 'Microsoft BizTalk Server Application ''Dummy.BizTalk.Application'' has been removed\.$' }
            }
        }

    }
}
