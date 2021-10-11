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

Describe 'Update-BizTalkHost' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host_1 -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHost -Name Test_Host_2 -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHost -Name Test_Host_3 -Type InProcess -Group 'BizTalk Application Users'
    }
    InModuleScope BizTalk.Administration {

        Context 'When BizTalk Server Host already exists' {
            It 'Updates a BizTalk Server Host.' {
                Test-BizTalkHost -Name Test_Host_1 | Should -BeTrue
                $btsHost = Get-BizTalkHost -Name Test_Host_1 -Detailed
                $btsHost.AuthTrusted | Should -BeFalse
                $btsHost.IsDefault | Should -BeFalse
                $btsHost.IsHost32BitOnly | Should -BeFalse
                $btsHost.HostTracking | Should -BeFalse

                { Update-BizTalkHost -Name Test_Host_1 -x86 -Tracking -Trusted } | Should -Not -Throw

                $btsHost = Get-BizTalkHost -Name Test_Host_1 -Detailed
                $btsHost.AuthTrusted | Should -BeTrue
                $btsHost.IsDefault | Should -BeFalse
                $btsHost.IsHost32BitOnly | Should -BeTrue
                $btsHost.HostTracking | Should -BeTrue
            }
        }

        Context 'When BizTalk Server Host does not exist' {
            It 'Skips BizTalk Server Host update.' {
                Mock -CommandName Write-Warning
                Test-BizTalkHost -Name Test_Host_4 | Should -BeFalse
                { Update-BizTalkHost -Name Test_Host_4 -x86 } | Should -Not -Throw
                Should -Invoke -CommandName Write-Warning -ParameterFilter { $Message -eq ($hostMessages.Error_Not_Found -f 'Test_Host_4') }
            }
        }

        Context 'Updating BizTalk Server Hosts from the pipeline' {
            It 'Updates the BizTalk Server Hosts.' {
                $btsHost = Get-BizTalkHost -Name Test_Host_2 -Detailed
                $btsHost.IsHost32BitOnly | Should -BeFalse
                $btsHost = Get-BizTalkHost -Name Test_Host_3 -Detailed
                $btsHost.IsHost32BitOnly | Should -BeFalse
                { 'Test_Host_2', 'Test_Host_3' | Get-BizTalkHost | Update-BizTalkHost -x86 } | Should -Not -Throw
                $btsHost = Get-BizTalkHost -Name Test_Host_2 -Detailed
                $btsHost.IsHost32BitOnly | Should -BeTrue
                $btsHost = Get-BizTalkHost -Name Test_Host_3 -Detailed
                $btsHost.IsHost32BitOnly | Should -BeTrue
            }
        }

    }
    AfterAll {
        Remove-BizTalkHost -Name Test_Host_3 -WarningAction SilentlyContinue
        Remove-BizTalkHost -Name Test_Host_2 -WarningAction SilentlyContinue
        Remove-BizTalkHost -Name Test_Host_1 -WarningAction SilentlyContinue
    }
}