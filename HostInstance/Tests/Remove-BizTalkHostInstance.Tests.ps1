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

Describe 'Remove-BizTalkHostInstance' {
    BeforeAll {
        New-BizTalkHost -Name Test_Host_1 -Type Isolated -Group 'BizTalk Isolated Host Users'
        New-BizTalkHostInstance -Name Test_Host_1 -User BTS_USER -Password 'p@ssw0rd'
        New-BizTalkHost -Name Test_Host_2 -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHostInstance -Name Test_Host_2 -User BTS_USER -Password 'p@ssw0rd' -Started
        New-BizTalkHost -Name Test_Host_3 -Type InProcess -Group 'BizTalk Application Users'
    }
    InModuleScope HostInstance {

        Context 'When the host instance exists' {
            Mock -CommandName Write-Information -ModuleName HostInstance
            It 'Removes the Isolated host instance.' {
                Test-BizTalkHostInstance -Name Test_Host_1 | Should -BeTrue
                { Remove-BizTalkHostInstance -Name Test_Host_1 -InformationAction Continue } | Should -Not -Throw
                Test-BizTalkHostInstance -Name Test_Host_1 | Should -BeFalse
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName HostInstance -ParameterFilter { $MessageData -match "Removing Microsoft BizTalk Server 'Test_Host_1' Host Instance on '$($env:COMPUTERNAME)' server\.\.\." }
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName HostInstance -ParameterFilter { $MessageData -match "Microsoft BizTalk Server 'Test_Host_1' Host Instance on '$($env:COMPUTERNAME)' server has been removed\." }
            }
            It 'Removes the InProcess host instance even though it is started.' {
                Test-BizTalkHostInstance -Name Test_Host_2 -IsStarted | Should -BeTrue
                { Remove-BizTalkHostInstance -Name Test_Host_2 -InformationAction Continue } | Should -Not -Throw
                Test-BizTalkHostInstance -Name Test_Host_2 | Should -BeFalse
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName HostInstance -ParameterFilter { $MessageData -match "Removing Microsoft BizTalk Server 'Test_Host_2' Host Instance on '$($env:COMPUTERNAME)' server\.\.\." }
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName HostInstance -ParameterFilter { $MessageData -match "Microsoft BizTalk Server 'Test_Host_2' Host Instance on '$($env:COMPUTERNAME)' server has been removed\." }
            }
        }

        Context 'When the host instance does not exist' {
            Mock -CommandName Write-Information -ModuleName HostInstance
            It 'Skips the host instance removal.' {
                Test-BizTalkHostInstance -Name Test_Host_1 | Should -BeFalse
                { Remove-BizTalkHostInstance -Name Test_Host_1 -InformationAction Continue } | Should -Not -Throw
                Assert-MockCalled -Scope It -CommandName Write-Information -ModuleName HostInstance -ParameterFilter { $MessageData -match "Microsoft BizTalk Server 'Test_Host_1' Host Instance on '$($env:COMPUTERNAME)' server has already been removed\." }
            }
        }

        Context 'When the host instance has been partially created' {
            It 'Removes what has been created.' {
                $serverHostInstanceClass = Get-CimClass -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_ServerHost
                $serverHostInstance = New-CimInstance -CimClass $serverHostInstanceClass -ClientOnly -Property @{
                    ServerName           = $env:COMPUTERNAME
                    HostName             = 'Test_Host_3'
                    MgmtDbNameOverride   = ''
                    MgmtDbServerOverride = ''
                }
                Invoke-CimMethod -InputObject $serverHostInstance -MethodName Map -Arguments @{ } | Out-Null
                $hostInstanceClass = Get-CimClass -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance
                $hostInstance = New-CimInstance -ErrorAction Stop -CimClass $hostInstanceClass -ClientOnly -Property @{
                    Name                 = "Microsoft BizTalk Server Test_Host_3 $($env:COMPUTERNAME)"
                    HostName             = 'Test_Host_3'
                    MgmtDbNameOverride   = ''
                    MgmtDbServerOverride = ''
                }
                {
                    Invoke-CimMethod -ErrorAction Stop -InputObject $hostInstance -MethodName Install -Arguments @{
                        GrantLogOnAsService = $true
                        IsGmsaAccount       = $false
                        Logon               = 'BTS_USER'
                        Password            = 'wrong-password'
                    }
                } | Should -Throw
                Test-BizTalkHostInstance -Name Test_Host_3 | Should -BeTrue

                { Remove-BizTalkHostInstance -Name Test_Host_3 } | Should -Not -Throw

                Test-BizTalkHostInstance -Name Test_Host_3 | Should -BeFalse
                Get-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_HostInstance -Filter "HostName='Test_Host_3' and RunningServer='$($env:COMPUTERNAME)'" | Should -BeNullOrEmpty
                # TODO no clue on how to delete the MSBTS_ServerHost CIM instance, Remove-CimInstance does not work either
                Get-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_ServerHost -Filter "HostName='Test_Host_3' and ServerName='$($env:COMPUTERNAME)'" | Should -Not -BeNullOrEmpty
                Get-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_ServerHost -Filter "HostName='Test_Host_3' and ServerName='$($env:COMPUTERNAME)'" |
                    Select-Object -ExpandProperty IsMapped | Should -BeFalse
            }
        }

    }
    AfterAll {
        Remove-BizTalkHost -Name Test_Host_3
        Remove-BizTalkHost -Name Test_Host_2
        Remove-BizTalkHost -Name Test_Host_1
    }
}