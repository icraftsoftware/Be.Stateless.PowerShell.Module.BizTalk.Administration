#region Copyright & License

# Copyright © 2012 - 2022 François Chabot
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

Describe 'Get-BizTalkHost' {
   InModuleScope BizTalk.Administration {

      Context 'When the BizTalk Server Host does not exist in the BizTalk Server Group' {
         It 'Returns $null.' {
            Get-BizTalkHost -Name InexistentHost | Should -BeNullOrEmpty
         }
      }

      Context 'When the BizTalk Server Hosts do exist in the BizTalk Server Group' {
         It 'Returns all hosts.' {
            Get-BizTalkHost | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
         }
         It 'Returns a host.' {
            $btsHost = Get-BizTalkHost -Name BizTalkServerApplication
            $btsHost | Should -HaveCount 1
            $btsHost | Get-Member -MemberType Properties | ForEach-Object Name | Should -Not -Contain MessageDeliveryMaximumDelay
         }
         It 'Returns an isolated host.' {
            $btsHost = Get-BizTalkHost -Type Isolated
            $btsHost | Should -HaveCount 1
            $btsHost | Get-Member -MemberType Properties | ForEach-Object Name | Should -Not -Contain MessageDeliveryMaximumDelay
         }
         It 'Returns a host settings.' {
            $btsHost = Get-BizTalkHost -Name BizTalkServerApplication -Detailed
            $btsHost | Should -HaveCount 1
            $btsHost | Get-Member -MemberType Properties | ForEach-Object Name | Should -Contain MessageDeliveryMaximumDelay
         }
         It 'Returns an isolated host settings.' {
            $btsHost = Get-BizTalkHost -Type Isolated -Detailed
            $btsHost | Should -HaveCount 1
            $btsHost | Get-Member -MemberType Properties | ForEach-Object Name | Should -Contain MessageDeliveryMaximumDelay
         }
      }

      Context 'Retrieving BizTalk Server Hosts from the pipeline' {
         It 'Returns hosts.' {
            'BizTalkServerApplication', 'BizTalkServerIsolatedHost' | Get-BizTalkHost -Detailed | Should -HaveCount 2
         }
      }

   }
}