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

@{
    RootModule            = 'BizTalk.Administration.psm1'
    ModuleVersion         = '1.0.0.0'
    GUID                  = 'de802b43-c7a6-4580-a34b-ac805bbf813e'
    Author                = 'François Chabot'
    CompanyName           = 'be.stateless'
    Copyright             = '(c) 2012 - 2020 be.stateless. All rights reserved.'
    Description           = 'Commands to administrate, configure, and explore BizTalk Server.'
    ProcessorArchitecture = 'None'
    PowerShellVersion     = '5.0'
    NestedModules         = @()
    RequiredAssemblies    = @(
        '.\bin\Microsoft.BizTalk.ExplorerOM.dll',
        '.\bin\Microsoft.BizTalk.Operations.dll'
    )
    RequiredModules       = @(
        @{ ModuleName = 'Exec'; ModuleVersion = '1.0.21335.23673'; GUID = '83f4143a-79ee-49ee-a510-7770a0fc1644' }
        @{ ModuleName = 'Psx'; ModuleVersion = '1.0.21284.43438'; GUID = '217de01f-f2e1-460a-99a4-b8895d0dd071' }
    )

    AliasesToExport       = @()
    CmdletsToExport       = @()
    FunctionsToExport     = @(
        # RootModule
        'Assert-BizTalkServerInstalled',
        'Test-BizTalkServerInstalled',
        # Adapter.ps1
        'Assert-BizTalkAdapter',
        'Get-BizTalkAdapter',
        'New-BizTalkAdapter',
        'Remove-BizTalkAdapter',
        'Test-BizTalkAdapter',
        # Application.ps1
        'Assert-BizTalkApplication',
        'Get-BizTalkApplication',
        'New-BizTalkApplication',
        'Remove-BizTalkApplication',
        'Start-BizTalkApplication',
        'Stop-BizTalkApplication',
        'Test-BizTalkApplication',
        # Group.ps1
        'Get-BizTalkGroupSettings',
        # Handler.ps1
        'Assert-BizTalkHandler',
        'Get-BizTalkHandler',
        'New-BizTalkHandler',
        'Remove-BizTalkHandler',
        'Test-BizTalkHandler',
        # Host.ps1
        'Assert-BizTalkHost',
        'Get-BizTalkHost',
        'New-BizTalkHost',
        'Remove-BizTalkHost',
        'Test-BizTalkHost',
        'Update-BizTalkHost',
        # HostInstance.ps1
        'Assert-BizTalkHostInstance',
        'Disable-BizTalkHostInstance',
        'Enable-BizTalkHostInstance',
        'Get-BizTalkHostInstance',
        'New-BizTalkHostInstance',
        'Remove-BizTalkHostInstance',
        'Restart-BizTalkHostInstance',
        'Start-BizTalkHostInstance',
        'Stop-BizTalkHostInstance',
        'Test-BizTalkHostInstance',
        # Platform.ps1
        'Get-BizTalkCatalog',
        'Get-BizTalkController',
        # Server.ps1
        'Assert-BizTalkServer',
        'Get-BizTalkServer',
        'Test-BizTalkServer'
    )
    VariablesToExport     = @()
    PrivateData           = @{
        PSData = @{
            Tags                       = @('BizTalk', 'Administration', 'Adapter', 'Application', 'Handler', 'Host', 'HostInstance')
            LicenseUri                 = 'https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.BizTalk.Administration/blob/master/LICENSE'
            ProjectUri                 = 'https://github.com/icraftsoftware/Be.Stateless.PowerShell.Module.BizTalk.Administration'
            ExternalModuleDependencies = @('Exec', 'Psx')
        }
    }
}