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

Set-StrictMode -Version Latest

<#
.SYNOPSIS
   Gets the WMI object instance representing a logical grouping of Microsoft BizTalk Servers.
.DESCRIPTION
   Gets the WMI object instance representing a logical grouping of Microsoft BizTalk Servers.
.EXAMPLE
   PS> Get-BizTalkGroupSettings
.LINK
   https://docs.microsoft.com/en-us/biztalk/core/technical-reference/msbts-groupsetting-wmi
.NOTES
   © 2022 be.stateless.
#>
function Get-BizTalkGroupSettings {
   [CmdletBinding()]
   [OutputType([PSCustomObject])]
   param()
   Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
   Get-CimInstance -Namespace root\MicrosoftBizTalkServer -ClassName MSBTS_GroupSetting
}

<#
.SYNOPSIS
   Gets the database name of the initial catalog part of the Microsoft BizTalk Management database connection string.
.DESCRIPTION
   Gets the database name of the initial catalog part of the Microsoft BizTalk Management database connection string.
.EXAMPLE
   PS> Get-BizTalkGroupMgmtDbName
.LINK
   https://docs.microsoft.com/en-us/biztalk/core/technical-reference/msbts-groupsetting-mgmtdbname-property-wmi
.NOTES
   © 2022 be.stateless.
#>
function Get-BizTalkGroupMgmtDbName {
   [CmdletBinding()]
   [OutputType([string])]
   param()
   Get-CimInstance -Namespace root\MicrosoftBizTalkServer -ClassName MSBTS_GroupSetting | Select-Object -ExpandProperty MgmtDbName
}

<#
.SYNOPSIS
   Gets the data source part of the BizTalk Management database connect string.
.DESCRIPTION
   Gets the data source part of the BizTalk Management database connect string.
.EXAMPLE
   PS> Get-BizTalkGroupMgmtDBServer
.LINK
   https://docs.microsoft.com/en-us/biztalk/core/technical-reference/msbts-groupsetting-mgmtdbservername-property-wmi
.NOTES
   © 2022 be.stateless.
#>
function Get-BizTalkGroupMgmtDBServer {
   [CmdletBinding()]
   [OutputType([string])]
   param()
   Get-CimInstance -Namespace root\MicrosoftBizTalkServer -ClassName MSBTS_GroupSetting | Select-Object -ExpandProperty MgmtDbServerName
}
