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

Describe 'New-BizTalkHostInstance' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host_1 -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHost -Name Test_Host_2 -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHost -Name Test_Host_3 -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHost -Name Test_Host_4 -Type Isolated -Group 'BizTalk Isolated Host Users'
        New-BizTalkHost -Name Test_Host_5 -Type InProcess -Group 'BizTalk Application Users'
    }
    InModuleScope HostInstance {

        Context 'When the host instance does not already exist' {
            Mock -CommandName Write-Information -ModuleName HostInstance
            It 'Creates a new InProcess host instance.' {
                Test-BizTalkHostInstance -Name Test_Host_1 | Should -BeFalse
                { New-BizTalkHostInstance -Name Test_Host_1 -User BTS_USER -Password 'p@ssw0rd' -InformationAction Continue } | Should -Not -Throw
                Test-BizTalkHostInstance -Name Test_Host_1 | Should -BeTrue
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName HostInstance -ParameterFilter { $MessageData -match "'Test_Host_1' Host Instance on '$($env:COMPUTERNAME)' server has been created." }
            }
            It 'Creates a new InProcess host instance and starts it.' {
                Test-BizTalkHostInstance -Name Test_Host_2 | Should -BeFalse
                { New-BizTalkHostInstance -Name Test_Host_2 -User BTS_USER -Password 'p@ssw0rd' -Started } | Should -Not -Throw
                Test-BizTalkHostInstance -Name Test_Host_2 | Should -BeTrue
                # https://docs.microsoft.com/en-us/biztalk/core/technical-reference/msbts-hostinstance-servicestate-property-wmi
                Get-BizTalkHostInstance Test_Host_2 | Select-Object -ExpandProperty ServiceState | Should -Be 4
            }
            It 'Creates a new InProcess host instance and disables it from starting.' {
                Test-BizTalkHostInstance -Name Test_Host_3 | Should -BeFalse
                { New-BizTalkHostInstance -Name Test_Host_3 -User BTS_USER -Password 'p@ssw0rd' -Disabled } | Should -Not -Throw
                Test-BizTalkHostInstance -Name Test_Host_3 | Should -BeTrue
                Get-BizTalkHostInstance -Name Test_Host_3 | Select-Object -ExpandProperty IsDisabled | Should -BeTrue
            }
            It 'Creates a new Isolated host instance' {
                Test-BizTalkHostInstance -Name Test_Host_4 | Should -BeFalse
                { New-BizTalkHostInstance -Name Test_Host_4 -User BTS_USER -Password 'p@ssw0rd' -InformationAction Continue } | Should -Not -Throw
                Test-BizTalkHostInstance -Name Test_Host_4 | Should -BeTrue
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName HostInstance -ParameterFilter { $MessageData -match "'Test_Host_4' Host Instance on '$($env:COMPUTERNAME)' server has been created." }
            }
        }

        Context 'When the host instance already exists' {
            Mock -CommandName Write-Information -ModuleName HostInstance
            It 'Skips the host instance creation.' {
                Test-BizTalkHostInstance -Name Test_Host_1 | Should -BeTrue
                { New-BizTalkHostInstance -Name Test_Host_1 -User BTS_USER -Password 'p@ssw0rd' -InformationAction Continue } | Should -Not -Throw
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName HostInstance -ParameterFilter { $MessageData -match "'Test_Host_1' Host Instance on '$($env:COMPUTERNAME)' server already exists." }
            }
        }

        Context 'When the host instance creation fails and is partially created' {
            It 'Cleans up partially created host intance.' {
                Test-BizTalkHostInstance -Name Test_Host_5 | Should -BeFalse

                { New-BizTalkHostInstance -Name Test_Host_5 -User BTS_USER -Password 'wrong-password' } | Should -Throw

                Test-BizTalkHostInstance -Name Test_Host_5 | Should -BeFalse
                Get-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance -Filter "HostName='Test_Host_5' and RunningServer='$($env:COMPUTERNAME)'" | Should -BeNullOrEmpty
                # TODO no clue on how to delete the MSBTS_ServerHost CIM instance, Remove-CimInstance does not work either
                Get-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_ServerHost -Filter "HostName='Test_Host_5' and ServerName='$($env:COMPUTERNAME)'" | Should -Not -BeNullOrEmpty
                Get-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_ServerHost -Filter "HostName='Test_Host_5' and ServerName='$($env:COMPUTERNAME)'" |
                    Select-Object -ExpandProperty IsMapped | Should -BeFalse
            }
        }

    }
    AfterAll {
        Stop-BizTalkHostInstance -Name Test_Host_2
        Remove-BizTalkHost -Name Test_Host_5
        Remove-BizTalkHost -Name Test_Host_4
        Remove-BizTalkHost -Name Test_Host_3
        Remove-BizTalkHost -Name Test_Host_2
        Remove-BizTalkHost -Name Test_Host_1
    }
}