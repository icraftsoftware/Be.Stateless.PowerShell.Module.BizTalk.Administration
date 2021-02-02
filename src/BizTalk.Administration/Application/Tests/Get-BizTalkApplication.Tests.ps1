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

Describe 'Get-BizTalkApplication' {
    InModuleScope BizTalk.Administration {

        Context 'Enumerating Microsoft BizTalk Server Applications' {
            It 'By name returns one application when found.' {
                Get-BizTalkApplication -Name 'BizTalk.System' | Should -Not -BeNullOrEmpty
            }
            It 'By name returns nothing when no application could be found.' {
                Get-BizTalkApplication -Name 'None' | Should -BeNullOrEmpty
            }
            It 'Without name returns all the applications.' {
                Get-BizTalkApplication | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
            }
        }

    }
}
