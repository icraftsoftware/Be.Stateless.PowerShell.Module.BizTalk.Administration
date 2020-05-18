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

@{
    RootModule            = 'BizTalk.Administration.psm1'
    ModuleVersion         = '1.0.0.1'
    GUID                  = 'de802b43-c7a6-4580-a34b-ac805bbf813e'
    Author                = 'François Chabot'
    CompanyName           = 'be.stateless'
    Copyright             = '(c) 2012 - 2020 be.stateless. All rights reserved.'
    Description           = 'Commands to administrate, configure, and explore BizTalk Server.'
    ProcessorArchitecture = 'None'
    PowerShellVersion     = '5.0'
    NestedModules         = @(
        'Adapter\Adapter.psm1',
        'Application\Application.psm1',
        'Group\Group.psm1',
        'Handler\Handler.psm1',
        'Host\Host.psm1',
        'HostInstance\HostInstance.psm1',
        'Platform\Platform.psm1'
    )
    RequiredAssemblies    = @(
        'Microsoft.BizTalk.ExplorerOM.dll',
        'Microsoft.BizTalk.Operations.dll'
    )
    RequiredModules       = @('Exec', 'Psx')

    AliasesToExport       = @()
    CmdletsToExport       = @()
    FunctionsToExport     = @(
        # RootModule
        'Assert-BizTalkServer',
        'Test-BizTalkServer',
        # Adapter.psm1
        'Get-BizTalkAdapter',
        'New-BizTalkAdapter',
        'Remove-BizTalkAdapter',
        'Test-BizTalkAdapter',
        # Application.psm1
        'Get-BizTalkApplication',
        'New-BizTalkApplication',
        'Remove-BizTalkApplication',
        'Stop-BizTalkApplication',
        'Test-BizTalkApplication',
        # Group.psm1
        'Get-BizTalGroupSettings',
        # Handler.psm1
        'Get-BizTalkHandler',
        'New-BizTalkHandler',
        'Remove-BizTalkHandler',
        'Test-BizTalkHandler',
        # Host.psm1
        'Assert-BizTalkHost',
        'Get-BizTalkHost',
        'New-BizTalkHost',
        'Remove-BizTalkHost',
        'Test-BizTalkHost',
        'Update-BizTalkHost',
        # HostInstance.psm1
        'Disable-BizTalkHostInstance',
        'Enable-BizTalkHostInstance',
        'Get-BizTalkHostInstance',
        'New-BizTalkHostInstance',
        'Remove-BizTalkHostInstance',
        'Restart-BizTalkHostInstance',
        'Start-BizTalkHostInstance',
        'Stop-BizTalkHostInstance',
        'Test-BizTalkHostInstance',
        # Platform.psm1
        'Get-BizTalkCatalog',
        'Get-BizTalkController'
    )
    VariablesToExport     = @()

    PrivateData           = @{ }
}