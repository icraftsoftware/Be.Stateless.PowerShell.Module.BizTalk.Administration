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

Describe 'Remove-BizTalkHostInstance' {
    BeforeAll {
        $credential = New-Object -TypeName PSCredential -ArgumentList '.\BTS_USER', (ConvertTo-SecureString p@ssw0rd -AsPlainText -Force)
        New-BizTalkHost -Name Test_Host_1 -Type Isolated -Group 'BizTalk Isolated Host Users'
        New-BizTalkHostInstance -Name Test_Host_1 -Credential $credential
        New-BizTalkHost -Name Test_Host_2 -Type InProcess -Group 'BizTalk Application Users'
        New-BizTalkHostInstance -Name Test_Host_2 -Credential $credential -Started
        New-BizTalkHost -Name Test_Host_3 -Type InProcess -Group 'BizTalk Application Users'
    }
    InModuleScope BizTalk.Administration {

        Context 'When the host instance exists' {
            It 'Removes the Isolated host instance.' {
                Mock -CommandName Write-Information
                Test-BizTalkHostInstance -Name Test_Host_1 | Should -BeTrue
                { Remove-BizTalkHostInstance -Name Test_Host_1 } | Should -Not -Throw
                Test-BizTalkHostInstance -Name Test_Host_1 | Should -BeFalse
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -eq ($hostInstanceMessages.Info_Removing -f 'Test_Host_1', $env:COMPUTERNAME) }
                Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -eq ($hostInstanceMessages.Info_Removed -f 'Test_Host_1', $env:COMPUTERNAME) }
            }
            It 'Removes the InProcess host instance even though it is started.' {
                Test-BizTalkHostInstance -Name Test_Host_2 -IsStarted | Should -BeTrue
                { Remove-BizTalkHostInstance -Name Test_Host_2 } | Should -Not -Throw
                Test-BizTalkHostInstance -Name Test_Host_2 | Should -BeFalse
            }
        }

        Context 'When the host instance does not exist' {
            It 'Skips the host instance removal.' {
                Mock -CommandName Write-Warning
                Test-BizTalkHostInstance -Name Test_Host_1 | Should -BeFalse
                { Remove-BizTalkHostInstance -Name Test_Host_1 } | Should -Not -Throw
                Should -Invoke -CommandName Write-Warning -ParameterFilter { $Message -eq ($hostInstanceMessages.Error_Not_Found_On_Any_Server -f 'Test_Host_1') }
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
                $arguments = @{ GrantLogOnAsService = $true ; Logon = '.\BTS_USER' ; Password = 'wrong-password' }
                if (Test-GmsaAccountSupport) { $arguments.IsGmsaAccount = $false }
                { Invoke-CimMethod -ErrorAction Stop -InputObject $hostInstance -MethodName Install -Arguments $arguments | Out-Null } | Should -Throw
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

        Context 'Removing BizTalk Server Host Instances from the pipeline' {
            It 'Removes hosts.' {
                { 'Test_Host', 'Test_Host_2' | Get-BizTalkHostInstance | Remove-BizTalkHostInstance } | Should -Not -Throw
            }
        }

    }
    AfterAll {
        Remove-BizTalkHost -Name Test_Host_3
        Remove-BizTalkHost -Name Test_Host_2
        Remove-BizTalkHost -Name Test_Host_1
    }
}