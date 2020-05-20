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

Describe 'Test-BizTalkHost' {
    InModuleScope Host {

        Context 'Testing the existence of BizTalk Server Hosts' {
            It 'Returns $true when the host exists.' {
                Test-BizTalkHost -Name BizTalkServerApplication | Should -BeTrue
            }
            It 'Returns $false when the host exists.' {
                Test-BizTalkHost -Name InexistentHost | Should -BeFalse
            }
        }

    }
}