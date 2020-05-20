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

Describe 'Update-BizTalkHost' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host -Type InProcess -Group 'BizTalk Application Users'
    }
    InModuleScope Host {

        Context 'When BizTalk Server Host already exists' {
            It 'Updates a BizTalk Server Host.' {
                Test-BizTalkHost -Name Test_Host | Should -BeTrue
                $btsHost = Get-BizTalkHost -Name Test_Host -Detailed
                $btsHost.AuthTrusted | Should -BeFalse
                $btsHost.IsDefault | Should -BeFalse
                $btsHost.IsHost32BitOnly | Should -BeFalse
                $btsHost.HostTracking | Should -BeFalse

                { Update-BizTalkHost -Name Test_Host -x86 $true -Tracking $true -Trusted $true } | Should -Not -Throw

                $btsHost = Get-BizTalkHost -Name Test_Host -Detailed
                $btsHost.AuthTrusted | Should -BeTrue
                $btsHost.IsDefault | Should -BeFalse
                $btsHost.IsHost32BitOnly | Should -BeTrue
                $btsHost.HostTracking | Should -BeTrue
            }
        }

        Context 'When BizTalk Server Host does not yet exist' {
            Mock -CommandName Write-Information -ModuleName Host
            It 'Skips BizTalk Server Host update.' {
                Test-BizTalkHost -Name Test_Host_2 | Should -BeFalse
                { Update-BizTalkHost -Name Test_Host_2 -x86 $true -InformationAction Continue } | Should -Not -Throw
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName Host -ParameterFilter { $MessageData -match '''Test_Host_2'' host does not exist.' }
            }
        }

    }
    AfterAll {
        Remove-BizTalkHost -Name Test_Host
    }
}