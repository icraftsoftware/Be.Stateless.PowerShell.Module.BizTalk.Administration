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

Import-Module -Name $PSScriptRoot\..\..\BizTalk.Administration.psm1 -Force

Describe 'Assert-BizTalkAdapter' {
    InModuleScope BizTalk.Administration {

        Context 'Asserting the existence of BizTalk Server Adapters' {
            It 'Does not throw when the adapter exists.' {
                { Assert-BizTalkAdapter -Name FILE -Source Combined } | Should -Not -Throw
            }
            It 'Throws when the adapter does not exist.' {
                { Assert-BizTalkAdapter -Name WCF-Siebel -Source Combined } | Should -Throw -ExpectedMessage 'Microsoft BizTalk Server Adapter ''WCF-Siebel'' does not exist in Combined source(s).'
            }
        }

    }
}