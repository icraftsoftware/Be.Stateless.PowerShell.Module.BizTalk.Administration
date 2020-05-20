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

Describe 'Get-BizTalkHost' {
    InModuleScope Host {

        Context 'Get information about BizTalk Server Hosts' {
            It 'Returns information about all hosts.' {
                Get-BizTalkHost | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
            }
            It 'Returns information about a given host.' {
                $btsHost = Get-BizTalkHost -Name BizTalkServerApplication
                $btsHost | Should -HaveCount 1
                $btsHost | Get-Member -MemberType Properties | ForEach-Object Name | Should -Not -Contain MessageDeliveryMaximumDelay
            }
            It 'Returns detailed information about a given host.' {
                $btsHost = Get-BizTalkHost -Name BizTalkServerApplication -Detailed
                $btsHost | Should -HaveCount 1
                $btsHost | Get-Member -MemberType Properties | ForEach-Object Name | Should -Contain MessageDeliveryMaximumDelay
            }
            It 'Returns nothing when the host does not exist.' {
                Get-BizTalkHost -Name InexistentHost | Should -BeNullOrEmpty
            }
        }

    }
}