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

Describe 'Get-BizTalkHostInstance' {
    InModuleScope BizTalk.Administration {

        Context 'When the BizTalk Server Host Instance does not exist' {
            It 'Returns $null.' {
                Get-BizTalkHostInstance -Name InexistentHost | Should -BeNullOrEmpty
            }
        }

        Context 'When the BizTalk Server Host Instances exist' {
            It 'Returns all host instances.' {
                Get-BizTalkHostInstance | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
            }
            It 'Returns a host instance by name.' {
                Get-BizTalkHostInstance -Name BizTalkServerIsolatedHost | Should -Not -BeNullOrEmpty
            }
            It 'Returns host instances by server.' {
                Get-BizTalkHostInstance -Server $env:COMPUTERNAME | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
            }
        }

        Context 'Retrieving BizTalk Server Host Instances from the pipeline' {
            It 'Returns host instances.' {
                'BizTalkServerApplication', 'BizTalkServerIsolatedHost' | Get-BizTalkHostInstance | Should -HaveCount 2
            }
        }

    }
}