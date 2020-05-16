#region Copyright & License

# Copyright © 2012 - 2022 François Chabot
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

Describe 'Start-BizTalkHostInstance' {
   BeforeAll {
      $credential = New-Object -TypeName PSCredential -ArgumentList '.\BTS_USER', (ConvertTo-SecureString p@ssw0rd -AsPlainText -Force)
      New-BizTalkHost -Name Test_Host_1 -Type Isolated -Group 'BizTalk Isolated Host Users'
      New-BizTalkHostInstance -Name Test_Host_1 -Credential $credential
      New-BizTalkHost -Name Test_Host_2 -Type InProcess -Group 'BizTalk Application Users'
      New-BizTalkHostInstance -Name Test_Host_2 -Credential $credential -Disabled
   }
   InModuleScope BizTalk.Administration {

      Context 'When the host instance exists' {
         It 'Skips starting a disabled host instance.' {
            Mock -CommandName Write-Warning
            Test-BizTalkHostInstance -Name Test_Host_2 -IsStopped -IsDisabled | Should -BeTrue
            { Start-BizTalkHostInstance -Name Test_Host_2 -InformationAction Continue } | Should -Not -Throw
            Test-BizTalkHostInstance -Name Test_Host_2 -IsStopped -IsDisabled | Should -BeTrue
            Should -Invoke -CommandName Write-Warning -ParameterFilter { $Message -eq ($hostInstanceMessages.Warn_Start_Disabled -f 'Test_Host_2', $env:COMPUTERNAME) }
            Enable-BizTalkHostInstance -Name Test_Host_2
            Test-BizTalkHostInstance -Name Test_Host_2 -IsStopped -IsDisabled:$false | Should -BeTrue
         }
         It 'Starts the host instance.' {
            Mock -CommandName Write-Information
            Test-BizTalkHostInstance -Name Test_Host_2 -IsStopped | Should -BeTrue
            { Start-BizTalkHostInstance -Name Test_Host_2 -InformationAction Continue } | Should -Not -Throw
            Test-BizTalkHostInstance -Name Test_Host_2 -IsStarted | Should -BeTrue
            Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -eq ($hostInstanceMessages.Info_Starting -f 'Test_Host_2', $env:COMPUTERNAME) }
            Should -Invoke -CommandName Write-Information -ParameterFilter { $MessageData -eq ($hostInstanceMessages.Info_Started -f 'Test_Host_2', $env:COMPUTERNAME) }
         }
         It 'Starts the host instance irrelevantly of whether it is already started.' {
            Test-BizTalkHostInstance -Name Test_Host_2 -IsStarted | Should -BeTrue
            { Start-BizTalkHostInstance -Name Test_Host_2 } | Should -Not -Throw
            Test-BizTalkHostInstance -Name Test_Host_2 -IsStarted | Should -BeTrue
         }
         It 'Skips starting an Isolated host instance.' {
            Mock -CommandName Write-Warning
            Test-BizTalkHostInstance -Name Test_Host_1 | Should -BeTrue
            { Start-BizTalkHostInstance -Name Test_Host_1 -InformationAction Continue } | Should -Not -Throw
            Should -Invoke -CommandName Write-Warning -ParameterFilter { $Message -eq ($hostInstanceMessages.Warn_Start_Stop_Isolated -f 'Test_Host_1', $env:COMPUTERNAME) }
         }
      }

      Context 'When the host instance does not exist' {
         It 'Skips starting the host instance.' {
            Mock -CommandName Write-Warning
            Test-BizTalkHostInstance -Name Test_Host_3 | Should -BeFalse
            { Start-BizTalkHostInstance -Name Test_Host_3 } | Should -Not -Throw
            Should -Invoke -CommandName Write-Warning -ParameterFilter { $Message -eq ($hostInstanceMessages.Error_Not_Found_On_Any_Server -f 'Test_Host_3') }
         }
      }

      Context 'Starting BizTalk Server Host Instances from the pipeline' {
         It 'Starts hosts.' {
            { 'Test_Host_1', 'Test_Host_2' | Get-BizTalkHostInstance | Start-BizTalkHostInstance -WarningAction SilentlyContinue } | Should -Not -Throw
         }
      }

   }
   AfterAll {
      Stop-BizTalkHostInstance -Name Test_Host_2
      Remove-BizTalkHost -Name Test_Host_2
      Remove-BizTalkHost -Name Test_Host_1
   }
}