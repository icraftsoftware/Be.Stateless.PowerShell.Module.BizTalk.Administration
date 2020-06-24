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

Import-Module -Name $PSScriptRoot\..\HostInstance -Force

Describe 'Get-BizTalkHostInstance' {
    InModuleScope HostInstance {

        Context 'Get information about BizTalk Server Host Instances' {
            It 'Returns information about a named host instances.' {
                Get-BizTalkHostInstance -Name BizTalkServerIsolatedHost | Should -Not -BeNullOrEmpty
            }
            It 'Returns information about all host instances bound to a server.' {
                Get-BizTalkHostInstance -Server $env:COMPUTERNAME | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
            }
            It 'Returns information about all host instances.' {
                Get-BizTalkHostInstance | Measure-Object | Select-Object -ExpandProperty Count | Should -BeGreaterThan 1
            }
        }

    }
}