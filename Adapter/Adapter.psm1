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
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.u
# See the License for the specific language governing permissions and
# limitations under the License.

#endregion

Set-StrictMode -Version Latest

<#
.SYNOPSIS
    Register an adapter in Microsoft BizTalk Server.
.DESCRIPTION
    Register an adapter in Microsoft BizTalk Server. The adapter to be registerd should be locally installed in order
    for its registration to succeed unless the MgmtCLSID is forced.
.PARAMETER Name
    The name of the Microsoft BizTalk Server adapter to register.
.PARAMETER MgmtCLSID
    The MgmtCLSID of the Microsoft BizTalk Server adapter to register. If the MgmtCLSID argument is omitted, it
    will lookup in the local machine's COM registry.
.PARAMETER Comment
    A descriptive comment of the Microsoft BizTalk Server adapter to register.
.EXAMPLE
    PS> New-BizTalkAdapter -Name 'WCF-SQL'
.EXAMPLE
    PS> New-BizTalkAdapter -Name 'WCF-SQL' -MgmtCLSID '{59B35D03-6A06-4734-A249-EF561254ECF7}'
.EXAMPLE
    PS> New-BizTalkAdapter -Name 'WCF-SQL' -Comment 'Windows Communication Foundation (WCF) in-process adapter for SQL Server.'
.NOTES
    © 2020 be.stateless.
#>
function New-BizTalkAdapter {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]
        $MgmtCLSID,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]
        $Comment
    )
    if (Test-BizTalkAdapter -Name $Name -Source BizTalk) {
        Write-Host "`t $Name adapter has already been registered in Microsoft BizTalk Server."
    } elseif ($PsCmdlet.ShouldProcess("BizTalk Group", "Registering $Name adapter")) {
        Write-Verbose "`t Registering $Name adapter in Microsoft BizTalk Server..."
        if ([string]::IsNullOrWhiteSpace($MgmtCLSID)) { $MgmtCLSID = Get-BizTalkAdapter -Name $Name -Source Registry | Select-Object -ExpandProperty MgmtCLSID }
        if ([string]::IsNullOrWhiteSpace($MgmtCLSID)) {
            throw "Cannot register $Name adapter in Microsoft BizTalk Server because its MgmtCLSID is unknown or cannot be found. The $Name adapter might not be locally installed on $($env:COMPUTERNAME)."
        }
        $properties = @{
            Name      = $Name
            MgmtCLSID = $MgmtCLSID
        }
        if (-not [string]::IsNullOrWhiteSpace($Comment)) { $properties.Comment = $Comment }
        $properties
        New-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_AdapterSetting -Property $properties | Out-Null
        Write-Verbose "`t $Name adapter in Microsoft BizTalk Server has been registered."
    }
}

<#
.SYNOPSIS
    Gets information about the Microsoft BizTalk Server adapters.
.DESCRIPTION
    Gets information about the Microsoft BizTalk Server adapters available in Microsoft BizTalk Server or the local
    machine's COM registry.
.PARAMETER Name
    The name of the Microsoft BizTalk Server adapter.
.PARAMETER Source
    The place where to look for the Microsoft BizTalk Server adapters: either among those configured and available
    in Microsoft BizTalk Server, or among those registered in the local machine's COM registry, or as a
    combination of both sources. It defaults to BizTalk.
.OUTPUTS
    Returns information about the Microsoft BizTalk Server adapters.
.EXAMPLE
    PS> Get-BizTalkAdapter
.EXAMPLE
    PS> Get-BizTalkAdapter -Name FILE
.EXAMPLE
    PS> Get-BizTalkAdapter -Source Registry
.EXAMPLE
    PS> Get-BizTalkAdapter -Name FILE -Source Biztalk
.EXAMPLE
    PS> Get-BizTalkAdapter -Name FILE -Source Combined
.LINK
    https://docs.microsoft.com/en-us/biztalk/core/registering-an-adapter
.NOTES
    © 2020 be.stateless.
#>
function Get-BizTalkAdapter {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Position = 0, Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]
        $Name,

        [Parameter(Position = 1, Mandatory = $false)]
        [ValidateSet('BizTalk', 'Registry', 'Combined')]
        [string]
        $Source = 'BizTalk'
    )

    function Get-BizTalkAdapterRegistryKey {
        [CmdletBinding()]
        [OutputType([Microsoft.Win32.RegistryKey[]])]
        param()
        Use-Object ($hklm = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry32)) {
            Use-Object ($clsidKey = $hklm.OpenSubKey('SOFTWARE\Classes\CLSID')) {
                $clsidKey.GetSubKeyNames() | ForEach-Object -Process {
                    Use-Object ($clsid = $clsidKey.OpenSubKey($_)) {
                        Use-Object ($adapterCategoryKey = $clsid.OpenSubKey('Implemented Categories\{7F46FC3E-3C2C-405B-A47F-8D17942BA8F9}')) {
                            if ($null -ne $adapterCategoryKey) {
                                Use-Object ($adapterKey = $clsid.OpenSubKey('BizTalk')) {
                                    $adapterKey
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function ConvertTo-BizTalkAdapterObject {
        [CmdletBinding()]
        [OutputType([PSCustomObject])]
        param(
            [Parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [Microsoft.Win32.RegistryKey]
            $Key
        )
        $adapter = [PSCustomObject]@{ Source = @('Registry') ; MgmtCLSID = ($Key.Name | Split-Path | Split-Path -Leaf) }
        $Key.GetValueNames() | Where-Object -FilterScript { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object -Process {
            Add-Member -InputObject $adapter -NotePropertyName $_ -NotePropertyValue $Key.GetValue($_)
        }
        $adapter
    }

    function Merge-BizTalkAdapterObjects {
        [CmdletBinding()]
        [OutputType([PSCustomObject])]
        param(
            [Parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [PSCustomObject]
            $BizTalkAdapter,

            [Parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [PSCustomObject]
            $RegistryAdapter
        )
        # if ($BizTalkAdapter.Constraints -ne $RegistryAdapter.Constraints) {
        #     throw "BizTalk '$($BizTalkAdapter.Name)' adapter and its corresponding Registry have different 'Constraints' property values ($($BizTalkAdapter.Constraints), $($RegistryAdapter.Constraints))."
        # }
        $adapter = [PSCustomObject]@{
            Source      = @('BizTalk', 'Registry')
            MgmtCLSID   = $BizTalkAdapter.MgmtCLSID
            Constraints = @(($BizTalkAdapter.Constraints, $RegistryAdapter.Constraints) | Select-Object -Unique)
        }
        $BizTalkAdapter | Get-Member -MemberType Properties | Where-Object -FilterScript { $_.Name -notin @('Source', 'MgmtCLSID', 'Constraints') } | ForEach-Object -Process {
            Add-Member -InputObject $adapter -NotePropertyName $_.Name -NotePropertyValue $BizTalkAdapter.($_.Name)
        }
        $RegistryAdapter | Get-Member -MemberType Properties | Where-Object -FilterScript { $_.Name -notin @('Source', 'MgmtCLSID', 'Constraints') } | ForEach-Object -Process {
            Add-Member -InputObject $adapter -NotePropertyName $_.Name -NotePropertyValue $RegistryAdapter.($_.Name)
        }
        $adapter
    }

    if ($Source -eq 'BizTalk') {
        $filter = if (![string]::IsNullOrWhiteSpace($Name)) { "Name='$Name'" }
        Get-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_AdapterSetting -Filter $filter |
            Add-Member -NotePropertyName Source -NotePropertyValue @($Source) -PassThru
    } elseif ($Source -eq 'Registry') {
        if ([string]::IsNullOrWhiteSpace($Name)) {
            Get-BizTalkAdapterRegistryKey | ForEach-Object -Process { ConvertTo-BizTalkAdapterObject -Key $_ }
        } else {
            # speed up registry lookup by 1st looking MgmtCLSID in BizTalk
            $mgmtCLSID = Get-BizTalkAdapter -Name $Name -Source BizTalk | Select-Object -ExpandProperty MgmtCLSID
            if ($null -ne $mgmtCLSID) {
                Use-Object ($hklm = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry32)) {
                    Use-Object ($adapterKey = $hklm.OpenSubKey("SOFTWARE\Classes\CLSID\$mgmtCLSID\BizTalk")) {
                        if ($null -ne $adapterKey) {
                            ConvertTo-BizTalkAdapterObject -Key $adapterKey
                        }
                    }
                }
            } else {
                Get-BizTalkAdapterRegistryKey |
                    Where-Object -FilterScript { $_.GetValue('TransportType') -eq $Name } |
                    ForEach-Object -Process { ConvertTo-BizTalkAdapterObject -Key $_ }
            }
        }
    } else {
        $btsAdapters = @(Get-BizTalkAdapter -Name $Name -Source BizTalk)
        $btsMgmtClsIds = $btsAdapters | ForEach-Object MgmtCLSID
        $comAdapters = @(Get-BizTalkAdapter -Name $Name -Source Registry)
        $comMgmtClsIds = $comAdapters | ForEach-Object MgmtCLSID

        $commonMgmtClsIds = $btsMgmtClsIds | Where-Object -FilterScript { $comMgmtClsIds -contains $_ }
        $commonMgmtClsIds | ForEach-Object -Process {
            Merge-BizTalkAdapterObjects -BizTalkAdapter ($btsAdapters | Where-Object MgmtCLSID -eq $_) -RegistryAdapter ($comAdapters | Where-Object MgmtCLSID -eq $_)
        }

        $btsOnlyMgmtClsIds = $btsMgmtClsIds | Where-Object -FilterScript { $comMgmtClsIds -notcontains $_ }
        $btsAdapters | Where-Object -FilterScript { $_.MgmtCLSID -in $btsOnlyMgmtClsIds }

        $comOnlyMgmtClsIds = $comMgmtClsIds | Where-Object -FilterScript { $btsMgmtClsIds -notcontains $_ }
        $comAdapters | Where-Object -FilterScript { $_.MgmtCLSID -in $comOnlyMgmtClsIds }
    }
}

<#
.SYNOPSIS
    Unregister an adapter from Microsoft BizTalk Server.
.DESCRIPTION
    Unregister an adapter from Microsoft BizTalk Server.
.PARAMETER Name
    The name of the Microsoft BizTalk Server adapter to unregister.
.EXAMPLE
    PS> Remove-BizTalkAdapter -Name 'WCF-SQL'
.NOTES
    © 2020 be.stateless.
#>
function Remove-BizTalkAdapter {
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name
    )
    if (-not(Test-BizTalkAdapter -Name $Name -Source BizTalk)) {
        Write-Host "`t $Name adapter has not been registered in Microsoft BizTalk Server."
    } elseif ($PsCmdlet.ShouldProcess("BizTalk Group", "Unregistering $Name adapter")) {
        Write-Verbose "`t Unregistering $Name adapter from Microsoft BizTalk Server..."
        $filter = if (![string]::IsNullOrWhiteSpace($Name)) { "Name='$Name'" }
        $instance = Get-CimInstance -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_AdapterSetting -Filter $filter
        Remove-CimInstance -InputObject $instance
        Write-Verbose "`t $Name adapter has been unregistered from Microsoft BizTalk Server."
    }
}

<#
.SYNOPSIS
    Returns whether a Microsoft BizTalk Server adapter exists.
.DESCRIPTION
    This command will return $true if the Microsoft BizTalk Server adapter exists; $false otherwise. If the existence
    has to be tested for the combined sources, this command will return $true only if the Microsoft BizTalk Server
    adapter exists in both sources.
.PARAMETER Name
    The name of the Microsoft BizTalk Server adapter.
.PARAMETER Source
    The place where to look for the Microsoft BizTalk Server adapter: either among those configured and available
    in Microsoft BizTalk Server, or among those registered in the local machine's COM registry, or as a
    combination of both sources. It defaults to BizTalk.
.OUTPUTS
    $true if the Microsoft BizTalk Server adapter exists; $false otherwise.
.EXAMPLE
    PS> Test-BizTalkAdapter -Name FILE
.EXAMPLE
    PS> Test-BizTalkAdapter -Name FILE -Source Registry
.EXAMPLE
    PS> Test-BizTalkAdapter -Name FILE -Source Combined
.NOTES
    © 2020 be.stateless.
#>
function Test-BizTalkAdapter {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]
        $Name,

        [Parameter(Position = 1, Mandatory = $false)]
        [ValidateSet('BizTalk', 'Registry', 'Combined')]
        [string]
        $Source = 'BizTalk'
    )
    if ($Source -eq 'Combined') {
        (Test-BizTalkAdapter -Name $Name -Source BizTalk) -and (Test-BizTalkAdapter -Name $Name -Source Registry)
    } else {
        [bool](Get-BizTalkAdapter -Name $Name -Source $Source)
    }
}
