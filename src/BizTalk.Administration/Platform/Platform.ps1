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

using namespace Microsoft.BizTalk.ExplorerOM
using namespace Microsoft.BizTalk.Operations
using namespace System

Set-StrictMode -Version Latest

function Get-BizTalkCatalog {
    [CmdletBinding()]
    [OutputType([Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer])]
    param(
        [Parameter(Position = 0, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ManagementDatabaseServer = (Get-BizTalkGroupMgmtDbServer),

        [Parameter(Position = 1, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ManagementDatabaseName = (Get-BizTalkGroupMgmtDbName)
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    try {
        $catalog = New-Object BtsCatalogExplorer
        $catalog.ConnectionString = "Server=$ManagementDatabaseServer;Database=$ManagementDatabaseName;Integrated Security=SSPI;"
        $catalog.Refresh()
        $catalog
    } catch {
        $disposable = [IDisposable]$catalog
        if ($null -ne $disposable) {
            $disposable.Dispose()
        }
    }
}

function Get-BizTalkController {
    [CmdletBinding()]
    [OutputType([Microsoft.BizTalk.Operations.BizTalkOperations])]
    param(
        [Parameter(Position = 0, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ManagementDatabaseServer = (Get-BizTalkGroupMgmtDbServer),

        [Parameter(Position = 1, Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ManagementDatabaseName = (Get-BizTalkGroupMgmtDbName)
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    try {
        $controller = New-Object BizTalkOperations -ArgumentList $ManagementDatabaseServer, $ManagementDatabaseName
        $controller
    } catch {
        $disposable = [IDisposable]$controller
        if ($null -ne $disposable) {
            $disposable.Dispose()
        }
    }
}
