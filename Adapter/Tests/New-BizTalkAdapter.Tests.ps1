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

Describe 'New-BizTalkAdapter' {
    InModuleScope Adapter {

        Context 'When adapter is locally installed and not yet registered' {
            It 'Registers the adapter.' {
                $name = 'WCF-OracleEBS'
                Test-BizTalkAdapter -Name $name | Should -BeFalse
                { New-BizTalkAdapter -Name $name } | Should -Not -Throw
                Test-BizTalkAdapter -Name $name | Should -BeTrue
                { Remove-BizTalkAdapter -Name $name } | Should -Not -Throw
                Test-BizTalkAdapter -Name $name | Should -BeFalse
            }
        }

        Context 'When adapter is locally installed and already registered' {
            Mock -CommandName Write-Information -ModuleName Adapter
            It 'Skips the adapter registration.' {
                Test-BizTalkAdapter -Name FILE | Should -BeTrue
                { New-BizTalkAdapter -Name FILE -InformationAction Continue } | Should -Not -Throw
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName Adapter -ParameterFilter { $MessageData -match 'FILE adapter has already been registered in Microsoft BizTalk Server.$' }
            }
        }

        Context 'When adapter is not locally installed' {
            It 'Throws because its MgmtCLSID cannot be discovered.' {
                $name = 'WCF-OracleEBS-1'
                Test-BizTalkAdapter -Name $name | Should -BeFalse
                { New-BizTalkAdapter -Name $name } | Should -Throw -ExpectedMessage "$name Adapter's MgmtCLSID could not be resolved on the local machine. The $name adapter might not be installed on $($env:COMPUTERNAME)."
            }
            It 'Throws because its MgmtCLSID cannot be forced.' {
                $name = 'WCF-OracleEBS-2'
                $mgmtCLSID = '{5090c39c-6583-4f9c-be28-e3f4a64a4fa1}'
                Test-BizTalkAdapter -Name $name | Should -BeFalse
                { New-BizTalkAdapter -Name $name -MgmtCLSID $mgmtCLSID } | Should -Throw -ExpectedMessage "Adapter's MgmtCLSID $mgmtCLSID does not exist on the local machine. The $name adapter might not be installed on $($env:COMPUTERNAME)."
            }
        }

    }
}