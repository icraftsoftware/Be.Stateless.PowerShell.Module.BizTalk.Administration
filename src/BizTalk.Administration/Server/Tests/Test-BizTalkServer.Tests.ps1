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

Describe 'Test-BizTalkServer' {
    InModuleScope BizTalk.Administration {

        Context 'When the Server is not a member of the BizTalk Server Group' {
            It 'Returns $false.' {
                Test-BizTalkServer -Name Lilas -InformationAction Continue | Should -BeFalse
            }
        }

        Context 'When the Server is a member of the BizTalk Server Group' {
            It 'Returns $true.' {
                Test-BizTalkServer -Name $env:COMPUTERNAME -InformationAction Continue | Should -BeTrue
            }
        }

        Context 'When testing Servers in a BizTalk Server Group from the pipeline' {
            It 'Returns $true, $false.' {
                @($env:COMPUTERNAME, 'Lilas') | Test-BizTalkServer | Should -Be @($true, $false)
            }
        }

    }
}