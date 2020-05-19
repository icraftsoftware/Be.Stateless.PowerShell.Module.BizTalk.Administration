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

Describe 'New-BizTalkApplication' {
    InModuleScope Application {

        Context 'Creating BizTalk Server applications' {
            It 'Creates an application by name when none is existing yet.' {
                { New-BizTalkApplication -Name 'Dummy.BizTalk.Application' } | Should -Not -Throw
            }
            It 'Throws when an application with the same name already exists.' {
                { New-BizTalkApplication -Name 'Dummy.BizTalk.Application' } | Should -Throw -ExpectedMessage 'Command { BTSTask AddApp -ApplicationName:"$Name" }'
                Remove-BizTalkApplication -Name 'Dummy.BizTalk.Application'
            }
        }

    }
}
