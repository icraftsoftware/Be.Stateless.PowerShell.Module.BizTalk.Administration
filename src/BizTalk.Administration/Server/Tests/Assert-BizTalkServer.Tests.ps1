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

Describe 'Assert-BizTalkServer' {
    InModuleScope BizTalk.Administration {

        Context 'When the Server is not a member of the BizTalk Server Group' {
            It 'Throws.' {
                { Assert-BizTalkServer -Name Lilas } | Should -Throw -ExpectedMessage ($serverMessages.Error_Not_Found -f 'Lilas')
            }
        }

        Context 'When the Server is a member of the BizTalk Server Group' {
            It 'Does not throw.' {
                { Assert-BizTalkServer -Name $env:COMPUTERNAME -InformationAction Continue } | Should -Not -Throw
            }
        }

        Context 'When asserting Servers in a BizTalk Server Group from the pipeline' {
            It 'Does not throw.' {
                { @($env:COMPUTERNAME, $env:COMPUTERNAME) | Assert-BizTalkServer } | Should -Not -Throw
            }
            It 'Throws.' {
                { @($env:COMPUTERNAME, 'Lilas') | Assert-BizTalkServer } | Should -Throw -ExpectedMessage ($serverMessages.Error_Not_Found -f 'Lilas')
            }
        }

    }
}