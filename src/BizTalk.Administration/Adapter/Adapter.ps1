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
    Asserts the existence of a Microsoft BizTalk Server Adapter.
.DESCRIPTION
    This command will throw if the Microsoft BizTalk Server Adapter does not exist and will silently complete
    otherwise. If the existence has to be asserted for the combined sources, this command will silently complete only
    if the Microsoft BizTalk Server adapter exists in both sources.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Adapter.
.PARAMETER Source
    The place where to look for the Microsoft BizTalk Server Adapter: either among those configured and available
    in Microsoft BizTalk Server, or among those registered in the local machine's COM registry, or as a
    combination of both sources. It defaults to BizTalk.
.EXAMPLE
    PS> Assert-BizTalkAdapter -Name FILE
.EXAMPLE
    PS> Assert-BizTalkAdapter -Name FILE -Source Registry
.EXAMPLE
    PS> Assert-BizTalkAdapter -Name FILE -Source Combined
.EXAMPLE
    PS> Assert-BizTalkAdapter -Name FILE -Source Combined -Verbose
.NOTES
    © 2020 be.stateless.
#>
function Assert-BizTalkAdapter {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Position = 1, Mandatory = $false)]
        [ValidateSet('BizTalk', 'Registry', 'Combined')]
        [string]
        $Source = 'BizTalk'
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    if (-not(Test-BizTalkAdapter @PSBoundParameters)) { throw "Microsoft BizTalk Server Adapter '$Name' does not exist in $Source source(s)." }
    Write-Verbose "Microsoft BizTalk Server Adapter '$Name' exists in $Source source(s)."
}

<#
.SYNOPSIS
    Gets information about the Microsoft BizTalk Server Adapters.
.DESCRIPTION
    Gets information about the Microsoft BizTalk Server Adapters available in Microsoft BizTalk Server or the local
    machine's COM registry.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Adapter.
.PARAMETER Source
    The place where to look for the Microsoft BizTalk Server Adapters: either among those configured and available
    in Microsoft BizTalk Server, or among those registered in the local machine's COM registry, or as a combination
    of both sources. It defaults to BizTalk.
.OUTPUTS
    Returns information about the Microsoft BizTalk Server Adapters.
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

    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    if ($Source -eq 'BizTalk') {
        $filter = if (![string]::IsNullOrWhiteSpace($Name)) { "Name='$Name'" }
        Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_AdapterSetting -Filter $filter |
            Add-Member -NotePropertyName Source -NotePropertyValue @($Source) -PassThru
    } elseif ($Source -eq 'Registry') {
        if ([string]::IsNullOrWhiteSpace($Name)) {
            Get-BizTalkAdapterRegistryKey | ForEach-Object -Process { ConvertTo-BizTalkAdapterObject -Key $_ }
        } else {
            # speed up registry lookup by 1st looking up the MgmtCLSID in BizTalk
            $mgmtCLSID = Get-BizTalkAdapter -Name $Name -Source BizTalk | Select-Object -ExpandProperty MgmtCLSID
            if ($null -ne $mgmtCLSID) {
                Get-BizTalkAdapterRegistryKey -MgmtCLSID $mgmtCLSID |
                    Where-Object -FilterScript { $null -ne $_ } |
                    ForEach-Object -Process { ConvertTo-BizTalkAdapterObject -Key $_ }
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
    Creates a Microsoft BizTalk Server Adapter.
.DESCRIPTION
    Creates a Microsoft BizTalk Server Adapter. The adapter to be created should be locally installed in order for its
    creation to succeed.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Adapter to create.
.PARAMETER MgmtCLSID
    The MgmtCLSID of the Microsoft BizTalk Server Adapter to create. If the MgmtCLSID argument is omitted, it will
    be looked up in the local machine's COM registry.
.PARAMETER Comment
    A descriptive comment of the Microsoft BizTalk Server Adapter to create.
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
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    if (Test-BizTalkAdapter -Name $Name -Source BizTalk) {
        Write-Information "`t Microsoft BizTalk Server '$Name' adapter has already been created."
    } elseif ($PsCmdlet.ShouldProcess("Microsoft BizTalk Server Group", "Creating '$Name' adapter")) {
        Write-Information "`t Creating Microsoft BizTalk Server '$Name' adapter..."
        if ([string]::IsNullOrWhiteSpace($MgmtCLSID)) { $MgmtCLSID = Get-BizTalkAdapter -Name $Name -Source Registry | Select-Object -ExpandProperty MgmtCLSID }
        if ([string]::IsNullOrWhiteSpace($MgmtCLSID)) {
            throw "'$Name' adapter's MgmtCLSID could not be resolved on the local machine. The '$Name' adapter might not be installed on $($env:COMPUTERNAME)."
        }
        if ($null -eq (Get-BizTalkAdapterRegistryKey -MgmtCLSID $mgmtCLSID)) {
            throw "'$Name' adapter's MgmtCLSID $mgmtCLSID does not exist on the local machine. The '$Name' adapter might not be installed on $($env:COMPUTERNAME)."
        }
        $properties = @{
            Name      = $Name
            MgmtCLSID = $MgmtCLSID
        }
        if (-not [string]::IsNullOrWhiteSpace($Comment)) { $properties.Comment = $Comment }
        $properties
        New-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_AdapterSetting -Property $properties | Out-Null
        Write-Information "`t Microsoft BizTalk Server '$Name' adapter has been created."
    }
}

<#
.SYNOPSIS
    Removes a Microsoft BizTalk Server Adapter.
.DESCRIPTION
    Removes a Microsoft BizTalk Server Adapter.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Adapter to remove.
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
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    if (-not(Test-BizTalkAdapter -Name $Name -Source BizTalk)) {
        Write-Information "`t Microsoft BizTalk Server '$Name' adapter has already been removed."
    } elseif ($PsCmdlet.ShouldProcess("Microsoft BizTalk Server Group", "Removing '$Name' adapter")) {
        Write-Information "`t Removing Microsoft BizTalk Server '$Name' adapter..."
        $filter = if (![string]::IsNullOrWhiteSpace($Name)) { "Name='$Name'" }
        $instance = Get-CimInstance -ErrorAction Stop -Namespace root/MicrosoftBizTalkServer -ClassName MSBTS_AdapterSetting -Filter $filter
        Remove-CimInstance -ErrorAction Stop -InputObject $instance
        Write-Information "`t Microsoft BizTalk Server '$Name' adapter has been removed."
    }
}

<#
.SYNOPSIS
    Returns whether a Microsoft BizTalk Server Adapter exists.
.DESCRIPTION
    This command will return $true if the Microsoft BizTalk Server Adapter exists; $false otherwise. If the existence
    has to be tested for the combined sources, this command will return $true only if the Microsoft BizTalk Server
    adapter exists in both sources.
.PARAMETER Name
    The name of the Microsoft BizTalk Server Adapter whose availability or installation has to be tested.
.PARAMETER Source
    The place where to look for the Microsoft BizTalk Server Adapter: either among those configured and available
    in Microsoft BizTalk Server, or among those registered in the local machine's COM registry, or as a
    combination of both sources. It defaults to BizTalk.
.OUTPUTS
    $true if the Microsoft BizTalk Server Adapter exists; $false otherwise.
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
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Position = 1, Mandatory = $false)]
        [ValidateSet('BizTalk', 'Registry', 'Combined')]
        [string]
        $Source = 'BizTalk'
    )
    Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    if ($Source -eq 'Combined') {
        (Test-BizTalkAdapter -Name $Name -Source BizTalk) -and (Test-BizTalkAdapter -Name $Name -Source Registry)
    } else {
        [bool](Get-BizTalkAdapter -Name $Name -Source $Source)
    }
}

function Get-BizTalkAdapterRegistryKey {
    [CmdletBinding()]
    [OutputType([Microsoft.Win32.RegistryKey[]])]
    param(
        [Parameter(Position = 0, Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]
        $MgmtCLSID
    )
    Use-Object ($hklm = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry32)) {
        Use-Object ($clsidKey = $hklm.OpenSubKey('SOFTWARE\Classes\CLSID')) {
            $(if ([string]::IsNullOrWhiteSpace($MgmtCLSID)) { $clsidKey.GetSubKeyNames() } else { @($MgmtCLSID) }) | ForEach-Object -Process {
                Use-Object ($clsid = $clsidKey.OpenSubKey($_)) {
                    if ($null -ne $clsid) {
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
}

