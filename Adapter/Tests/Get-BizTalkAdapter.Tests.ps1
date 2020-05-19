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

Describe 'Get-BizTalkAdapter' {
    InModuleScope Adapter {

        Context 'Get information about locally installed adapters' {
            It 'Returns information from the COM registry.' {
                Get-BizTalkAdapter -Name FILE -Source Registry | Should -Not -BeNullOrEmpty
            }
            It 'Returns no information from the COM registry.' {
                Get-BizTalkAdapter -Name FTPS -Source Registry | Should -BeNullOrEmpty
            }
            It 'Returns information about all the adapters from the COM registry.' {
                Get-BizTalkAdapter -Source Registry | Should -Not -BeNullOrEmpty
            }
        }

        Context 'Get information about registered adapters' {
            It 'Returns information from BizTalk Server.' {
                Get-BizTalkAdapter -Name FILE -Source BizTalk | Should -Not -BeNullOrEmpty
            }
            It 'Returns no information from BizTalk Server.' {
                Get-BizTalkAdapter -Name 'WCF-Siebel' -Source BizTalk | Should -BeNullOrEmpty
            }
            It 'Returns information about all the adapters from BizTalk Server.' {
                Get-BizTalkAdapter -Source BizTalk | Should -Not -BeNullOrEmpty
            }
        }

        Context 'Get combined information about both installed and registered adapters' {
            It 'Returns information from both BizTalk Server and the COM Registry.' {
                $adapter = Get-BizTalkAdapter -Name FILE -Source Combined
                $adapter | Should -Not -BeNullOrEmpty
                $adapter.Source | Should -Be @('BizTalk', 'Registry')
            }
            It 'Returns information from the COM Registry only.' {
                $adapter = Get-BizTalkAdapter -Name 'WCF-Siebel' -Source Combined
                $adapter | Should -Not -BeNullOrEmpty
                $adapter.Source | Should -Be @('Registry')
            }
            It 'Returns no information from neither BizTalk Server nor the COM Registry.' {
                Get-BizTalkAdapter -Name FTPS -Source Combined | Should -BeNullOrEmpty
            }
            It 'Returns combined information about all the adapters from both BizTalk Server and the COM Registry.' {
                Get-BizTalkAdapter -Source Combined | Should -Not -BeNullOrEmpty
            }
        }

    }
}