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

Describe 'Test-BizTalkHandler' {
    InModuleScope Handler {

        Context 'Testing the existence of BizTalk Server Handlers' {
            It 'Returns $true for a given handler.' {
                Test-BizTalkHandler -Adapter FILE -Host BizTalkServerApplication -Direction Send | Should -BeTrue
            }
            It 'Returns $true for a given handler.' {
                Test-BizTalkHandler -Adapter FTPS -Host BizTalkServerApplication -Direction Send | Should -BeFalse
            }
        }

    }
}
