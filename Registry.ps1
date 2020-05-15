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

function Get-RegisteredMgmtDbName {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    if ($null -eq $MyInvocation.MyCommand.Module.PrivateData['MgmtDbName']) {
        $MyInvocation.MyCommand.Module.PrivateData['MgmtDbName'] = Get-BizTalkAdministrationRegistryKeyValue 'MgmtDBName'
    }
    $MyInvocation.MyCommand.Module.PrivateData['MgmtDbName']
}

function Get-RegisteredMgmtDbServer {
    [CmdletBinding()]
    [OutputType([string])]
    param()
    if ($null -eq $MyInvocation.MyCommand.Module.PrivateData['MgmtDbServer']) {
        $MyInvocation.MyCommand.Module.PrivateData['MgmtDbServer'] = Get-BizTalkAdministrationRegistryKeyValue 'MgmtDBServer'
    }
    $MyInvocation.MyCommand.Module.PrivateData['MgmtDbServer']
}

function Get-BizTalkAdministrationRegistryKeyValue {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]
        $Name
    )
    Use-Object ($hklm = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry32)) {
        $keyPath = 'SOFTWARE\Microsoft\Biztalk Server\3.0\Administration'
        Use-Object ($key = $hklm.OpenSubKey($keyPath)) {
            if ($null -eq $key) {
                throw "Cannot find registry key '$($hklm.Name)\$keyPath'"
            }
            [string]$key.GetValue($Name)
        }
    }
}
