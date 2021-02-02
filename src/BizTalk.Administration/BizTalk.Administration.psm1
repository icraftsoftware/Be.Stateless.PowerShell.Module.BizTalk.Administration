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
using assembly Microsoft.BizTalk.Operations

Set-StrictMode -Version Latest

<#
.SYNOPSIS
    Ensures Microsoft BizTalk Server is installed locally.
.DESCRIPTION
    This command will throw if Microsoft BizTalk Server is not installed locally and will silently complete otherwise.
.EXAMPLE
    PS> Assert-BizTalkServer
.EXAMPLE
    PS> Assert-BizTalkServer -Verbose
    When verbose, this function outputs a message confirming that Microsoft BizTalk Server is installed locally.
.NOTES
    © 2020 be.stateless.
#>
function Assert-BizTalkServer {
    [CmdletBinding()]
    [OutputType([void])]
    param()

    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    if (-not(Test-BizTalkServer)) { throw 'Microsoft BizTalk Server is not installed locally.' }
    Write-Verbose 'Microsoft BizTalk Server is installed locally.'
}

<#
.SYNOPSIS
    Returns whether Microsoft BizTalk Server is installed locally.
.DESCRIPTION
    This command will return $true if the Microsoft BizTalk Server is installed locally.
.EXAMPLE
    PS> Test-BizTalkServer
.NOTES
    © 2020 be.stateless.
#>
function Test-BizTalkServer {
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    Test-Path -Path 'HKLM:\SOFTWARE\Microsoft\BizTalk Server\3.0\*'
}

<#
 # Main
 #>

# Have BizTalk Tracking tools available on path, noticeably bm.exe
$path = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\BizTalk Server\3.0\' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty InstallPath
if ($null -ne $path) {
    $env:Path += ";$(Join-Path $path Tracking)"
}

. $PSScriptRoot\Adapter\Adapter.ps1
. $PSScriptRoot\Application\Application.ps1
. $PSScriptRoot\Group\Group.ps1
. $PSScriptRoot\Handler\Handler.ps1
. $PSScriptRoot\Host\Host.ps1
. $PSScriptRoot\HostInstance\HostInstance.ps1
. $PSScriptRoot\Platform\Platform.ps1
