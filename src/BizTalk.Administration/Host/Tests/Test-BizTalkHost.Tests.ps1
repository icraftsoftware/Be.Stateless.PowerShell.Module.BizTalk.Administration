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

Describe 'Test-BizTalkHost' {
   InModuleScope BizTalk.Administration {

      Context 'When the BizTalk Server Host does not exist in the BizTalk Server Group' {
         It 'Returns $false.' {
            Test-BizTalkHost -Name InexistentHost | Should -BeFalse
         }
      }

      Context 'When the BizTalk Server Hosts exist in the BizTalk Server Group' {
         It 'Returns $true.' {
            Test-BizTalkHost -Name BizTalkServerApplication | Should -BeTrue
         }
         It 'Returns $true if the host is of the given type.' {
            Test-BizTalkHost -Name BizTalkServerApplication -Type InProcess | Should -BeTrue
         }
         It 'Returns $false if the host is not of the given type.' {
            Test-BizTalkHost -Name BizTalkServerApplication -Type Isolated | Should -BeFalse
         }
         It 'Tests the host object passed in and returns $true if the host is of the given type.' {
            Test-BizTalkHost -Host @(Get-BizTalkHost -Name BizTalkServerApplication) -Type InProcess | Should -BeTrue
         }
      }

      Context 'Testing BizTalk Server Hosts from the pipeline' {
         It 'Returns test results.' {
            'BizTalkServerApplication', 'BizTalkServerIsolatedHost' | Get-BizTalkHost | Test-BizTalkHost -Type InProcess | Should -Be $true, $false
         }
      }

   }
}