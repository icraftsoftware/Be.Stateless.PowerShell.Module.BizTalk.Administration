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

Import-Module -Name $PSScriptRoot\..\Handler -Force

Describe 'Get-BizTalkHandler' {
    InModuleScope Handler {

        Context 'Get information about BizTalk Server Handlers' {
            It 'Returns information about all handlers associated to a given adapter.' {
                Get-BizTalkHandler -Adapter FILE | Should -Not -BeNullOrEmpty
            }
            It 'Returns information about all handlers associated to a given host.' {
                Get-BizTalkHandler -Host BizTalkServerApplication | Should -Not -BeNullOrEmpty
            }
            It 'Returns information about all handlers of a given direction.' {
                Get-BizTalkHandler -Direction Send | Should -Not -BeNullOrEmpty
            }
            It 'Returns information about one specific handler.' {
                Get-BizTalkHandler -Adapter FILE -Host BizTalkServerApplication -Direction Send | Should -HaveCount 1
            }
            It 'Returns information about all handlers.' {
                Get-BizTalkHandler -Adapter FILE | Should -Not -BeNullOrEmpty
            }
        }

    }
}
