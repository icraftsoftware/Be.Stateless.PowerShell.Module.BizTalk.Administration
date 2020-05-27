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

Describe 'New-BizTalkApplication' {
    InModuleScope Application {

        Context 'Creating Microsoft BizTalk Server Applications' {
            Mock -CommandName Write-Information -ModuleName Application
            It 'Creates an application by name when none is existing yet.' {
                { New-BizTalkApplication -Name 'Dummy.BizTalk.Application' -InformationAction Continue } | Should -Not -Throw
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName Application -ParameterFilter { $MessageData -match 'Creating Microsoft BizTalk Server Application ''Dummy.BizTalk.Application''\.\.\.$' }
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName Application -ParameterFilter { $MessageData -match 'Microsoft BizTalk Server Application ''Dummy.BizTalk.Application'' has been created\.$' }
            }
            It 'Skips application creation when it already exists.' {
                { New-BizTalkApplication -Name 'Dummy.BizTalk.Application' -InformationAction Continue } | Should -Not -Throw
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName Application -ParameterFilter { $MessageData -match 'Microsoft BizTalk Server Application ''Dummy.BizTalk.Application'' has already been created\.$' }
                Remove-BizTalkApplication -Name 'Dummy.BizTalk.Application'
            }
        }

    }
}
