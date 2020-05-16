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

Describe 'Test-BizTalkApplication' {
   InModuleScope BizTalk.Administration {

      Context 'Test Microsoft BizTalk Server Application existence' {
         It 'Returns $true when the application exists.' {
            Test-BizTalkApplication -Name BizTalk.System | Should -BeTrue
         }
         It 'Returns $false when the application does not exist.' {
            Test-BizTalkApplication -Name Dummy.BizTalk.Application | Should -BeFalse
         }
         It 'Returns $true when the application exists and references the given applications.' {
            Test-BizTalkApplication -Name 'BizTalk EDI Application' -Reference BizTalk.System | Should -BeTrue
         }
         It 'Returns $false when the application exists but is mistakenly tested for some application reference.' {
            Test-BizTalkApplication -Name BizTalk.System -Reference Unknown.Application | Should -BeFalse
         }
         It 'Returns $false when the application exists but does not reference one of the given applications.' {
            Test-BizTalkApplication -Name 'BizTalk EDI Application' -Reference BizTalk.System, Unknown.Application | Should -BeFalse
         }
         It 'Returns $false when the application exists but does not reference any of the given applications.' {
            Test-BizTalkApplication -Name 'BizTalk EDI Application' -Reference Dummy.BizTalk.Application, Unknown.Application | Should -BeFalse
         }
      }

   }
}
