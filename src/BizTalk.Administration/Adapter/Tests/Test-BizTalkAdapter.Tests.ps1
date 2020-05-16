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

Describe 'Test-BizTalkAdapter' {
   InModuleScope BizTalk.Administration {

      Context 'Test the existence of locally installed adapters' {
         It 'Returns $true based on information from the COM registry.' {
            Test-BizTalkAdapter -Name FILE -Source Registry | Should -BeTrue
         }
         It 'Returns $false based on information from the COM registry.' {
            Test-BizTalkAdapter -Name FTPS -Source Registry | Should -BeFalse
         }
      }

      Context 'Test the existence of registered adapters' {
         It 'Returns $true based on information from BizTalk Server.' {
            Test-BizTalkAdapter -Name FILE -Source BizTalk | Should -BeTrue
         }
         It 'Returns $false based on information from BizTalk Server.' {
            Test-BizTalkAdapter -Name 'WCF-Siebel' -Source BizTalk | Should -BeFalse
         }
      }

      Context 'Test the combined existence of installed and registered adapters' {
         It 'Returns $true when the adapter is both installed and registered.' {
            Test-BizTalkAdapter -Name FILE -Source Combined | Should -BeTrue
         }
         It 'Returns $false when the adapter is only either installed or registered.' {
            Test-BizTalkAdapter -Name 'WCF-Siebel' -Source Combined | Should -BeFalse
         }
         It 'Returns $false when the adapter is neither installed nor registered.' {
            Test-BizTalkAdapter -Name 'FTPS' -Source Combined | Should -BeFalse
         }
      }

   }
}