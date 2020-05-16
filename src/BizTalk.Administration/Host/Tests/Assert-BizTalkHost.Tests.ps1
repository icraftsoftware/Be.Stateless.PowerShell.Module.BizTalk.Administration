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

Describe 'Assert-BizTalkHost' {
   InModuleScope BizTalk.Administration {

      Context 'When the BizTalk Server Host does not exist in the BizTalk Server Group' {
         It 'Throws.' {
            { Assert-BizTalkHost -Name InexistentHost } | Should -Throw -ExpectedMessage ($hostMessages.Error_Not_Found -f 'InexistentHost')
         }
      }

      Context 'When the BizTalk Server Hosts exist in the BizTalk Server Group' {
         It 'Does not throw.' {
            { Assert-BizTalkHost -Name BizTalkServerApplication } | Should -Not -Throw
         }
         It 'Does not throw if the host is of the expected type.' {
            { Assert-BizTalkHost -Name BizTalkServerApplication -Type InProcess } | Should -Not -Throw
         }
         It 'Throws if the host is not of the expected type.' {
            { Assert-BizTalkHost -Name BizTalkServerApplication -Type Isolated } | Should -Throw -ExpectedMessage ($hostMessages.Error_Type -f 'BizTalkServerApplication')
         }
         It 'Asserts the host object passed in and does not throw if the host is of the expected type.' {
            { Assert-BizTalkHost -Host @(Get-BizTalkHost -Name BizTalkServerApplication) -Type InProcess } | Should -Not -Throw
         }
      }

      Context 'Asserting BizTalk Server Hosts from the pipeline' {
         It 'Throws.' {
            { 'BizTalkServerApplication', 'BizTalkServerIsolatedHost' | Get-BizTalkHost | Assert-BizTalkHost -Type InProcess } | Should -Throw -ExpectedMessage ($hostMessages.Error_Type -f 'BizTalkServerIsolatedHost')
         }
      }

   }
}