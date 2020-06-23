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

Import-Module -Name $PSScriptRoot\..\Application -Force

Describe 'Assert-BizTalkApplication' {
    InModuleScope Application {

        Context 'Asserting the existence of BizTalk Server Applications' {
            It 'Does not throw when the application exists.' {
                { Assert-BizTalkApplication -Name BizTalk.System } | Should -Not -Throw
            }
            It 'Throws when the application does not exist.' {
                { Assert-BizTalkApplication -Name Dummy.BizTalk.Application } | Should -Throw -ExpectedMessage 'Microsoft BizTalk Server Application ''Dummy.BizTalk.Application'' does not exist.'
            }
            It 'Does not throw when the application exists and references the given applications.' {
                { Assert-BizTalkApplication -Name 'BizTalk EDI Application' -References BizTalk.System } | Should -Not -Throw
            }
            It 'Throws when the application exists but is mistakenly tested for some application reference.' {
                { Assert-BizTalkApplication -Name BizTalk.System -References Unknown.Application } | Should -Throw -ExpectedMessage 'Microsoft BizTalk Server Application ''BizTalk.System'' does not exist or some the required application refereces ''Unknown.Application'' are missing.'
            }
            It 'Throws when the application exists but does not reference one of the given applications.' {
                { Assert-BizTalkApplication -Name 'BizTalk EDI Application' -References BizTalk.System, Unknown.Application } | Should -Throw -ExpectedMessage 'Microsoft BizTalk Server Application ''BizTalk EDI Application'' does not exist or some the required application refereces ''BizTalk.System'', ''Unknown.Application'' are missing.'
            }
            It 'Throws when the application exists but does not reference any of the given applications.' {
                { Assert-BizTalkApplication -Name 'BizTalk EDI Application' -References Dummy.BizTalk.Application, Unknown.Application } | Should -Throw -ExpectedMessage 'Microsoft BizTalk Server Application ''BizTalk EDI Application'' does not exist or some the required application refereces ''Dummy.BizTalk.Application'', ''Unknown.Application'' are missing.'
            }
        }

    }
}