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

Describe 'New-BizTalkApplication' {
    InModuleScope BizTalk.Administration {

        Context 'Creating Microsoft BizTalk Server Applications' {
            It 'Creates an application by name when none is existing yet.' {
                Mock -CommandName Write-Information
                { New-BizTalkApplication -Name 'Dummy.BizTalk.Application' -References 'BizTalk EDI Application' -InformationAction Continue } | Should -Not -Throw
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match 'Creating Microsoft BizTalk Server Application ''Dummy\.BizTalk\.Application''\.\.\.$' }
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match 'Adding Reference to Microsoft BizTalk Server Application ''BizTalk EDI Application'' from Microsoft BizTalk Server Application ''Dummy\.BizTalk\.Application''\.$' }
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match 'Microsoft BizTalk Server Application ''Dummy.BizTalk.Application'' has been created\.$' }
            }
            It 'Skips application creation when it already exists.' {
                Mock -CommandName Write-Information
                { New-BizTalkApplication -Name 'Dummy.BizTalk.Application' -InformationAction Continue } | Should -Not -Throw
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -match 'Microsoft BizTalk Server Application ''Dummy.BizTalk.Application'' has already been created\.$' }
                Remove-BizTalkApplication -Name 'Dummy.BizTalk.Application'
            }
            It 'Returns the application' {
                $application = New-BizTalkApplication -Name 'Dummy.BizTalk.Application'
                $application | Should -Not -BeNull
                $application | Should -BeOfType [Microsoft.BizTalk.ExplorerOM.Application]
                Remove-BizTalkApplication -Name 'Dummy.BizTalk.Application'
            }
        }

    }
}
