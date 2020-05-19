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

Import-Module -Name $PSScriptRoot\..\Adapter -Force

Describe 'Remove-BizTalkAdapter' {
    InModuleScope Adapter {

        Context 'When adapter is registered' {
            It 'Unregisters the adapter.' {
                $name = 'WCF-OracleEBS'
                Test-BizTalkAdapter -Name $name | Should -BeFalse
                { New-BizTalkAdapter -Name $name } | Should -Not -Throw
                Test-BizTalkAdapter -Name $name | Should -BeTrue
                { Remove-BizTalkAdapter -Name $name } | Should -Not -Throw
                Test-BizTalkAdapter -Name $name | Should -BeFalse
            }
        }

        Context 'When adapter is not registered' {
            Mock -CommandName Write-Information -ModuleName Adapter
            It 'Skips the adapter unregistration.' {
                $name = 'WCF-OracleEBS'
                Test-BizTalkAdapter -Name $name | Should -BeFalse
                { Remove-BizTalkAdapter -Name $name -InformationAction Continue } | Should -Not -Throw
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName Adapter -ParameterFilter { $MessageData -match "$name adapter has not been registered in Microsoft BizTalk Server\.$" }
            }
        }

    }
}