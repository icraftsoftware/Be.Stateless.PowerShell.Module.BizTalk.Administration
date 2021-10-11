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

Set-StrictMode -Version Latest

<#
.SYNOPSIS
    Asserts the existence of a server being a member of the Microsoft BizTalk Server Group.
.DESCRIPTION
    This command will throw if the server of a given name is not a member of the Microsoft BizTalk Server Group, and
    will silently complete otherwise.
.PARAMETER Name
    The name of the server to assert membership to Microsoft BizTalk Server Group.
.OUTPUTS
    Throws if server is not a member of the Microsoft BizTalk Server Group; completes silently otherwise.
.EXAMPLE
    PS> Assert-BizTalkServer -Name Artichaut
.EXAMPLE
    PS> Assert-BizTalkServer -Name Artichaut, Aubergine
.NOTES
    © 2021 be.stateless.
#>
function Assert-BizTalkServer {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyCollection()]
        [string[]]
        $Name
    )
    Begin {
        Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    }
    Process {
        Enumerate-BizTalkServer -Name $Name -UserBoundParameters $PSBoundParameters -ErrorAction Stop -WarningAction SilentlyContinue
    }
}

<#
.SYNOPSIS
    Gets all or one Microsoft BizTalk Server Group's Servers by name.
.DESCRIPTION
    This command returns the servers being members of BizTalk Server Group.
.PARAMETER Name
    The name of the server belonging to the Microsoft BizTalk Server Group.
.OUTPUTS
    Returns information about the server belonging to the Microsoft BizTalk Server Group.
.EXAMPLE
    PS> Get-BizTalkServer
.EXAMPLE
    PS> Get-BizTalkServer -Name Artichaut, Aubergine
.NOTES
    © 2021 be.stateless.
#>
function Get-BizTalkServer {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Name
    )
    Begin {
        Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    }
    Process {
        Enumerate-BizTalkServer -Name $Name -UserBoundParameters $PSBoundParameters -ErrorAction SilentlyContinue -WarningAction SilentlyContinue |
            Where-Object -FilterScript { $_ }
    }
}

<#
.SYNOPSIS
    Returns whether a server is a member of the Microsoft BizTalk Server Group.
.DESCRIPTION
    This command will return $true if the server of a given name is a member of the Microsoft BizTalk Server Group.
.PARAMETER Name
    The name of the server to test membership to Microsoft BizTalk Server Group.
.OUTPUTS
    Returns $true if server if a member of the Microsoft BizTalk Server Group; $false otherwise.
.EXAMPLE
    PS> Test-BizTalkServer -Name Artichaut
.EXAMPLE
    PS> Test-BizTalkServer -Name Artichaut, Aubergine
.NOTES
    © 2021 be.stateless.
#>
function Test-BizTalkServer {
    [CmdletBinding()]
    [OutputType([bool[]])]
    param(
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [AllowEmptyCollection()]
        [string[]]
        $Name
    )
    Begin {
        Resolve-ActionPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    }
    Process {
        Enumerate-BizTalkServer -Name $Name -UserBoundParameters $PSBoundParameters -ErrorAction SilentlyContinue -WarningAction SilentlyContinue |
            ForEach-Object -Process { [bool]$_ }
    }
}

function Enumerate-BizTalkServer {
    [Diagnostics.CodeAnalysis.SuppressMessage('PSUseApprovedVerbs', '', Justification = 'Non-public function.')]
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [AllowNull()]
        [string[]]
        $Name,

        [Parameter(Mandatory = $true)]
        [HashTable]
        $UserBoundParameters
    )

    function Enumerate-BizTalkServerCore {
        [CmdletBinding()]
        [OutputType([PSCustomObject[]])]
        param(
            [Parameter(Mandatory = $false)]
            [AllowEmptyString()]
            [AllowEmptyCollection()]
            [AllowNull()]
            [string[]]
            $Name = '' # default value ensures its pipeline will run
        )
        $Name | ForEach-Object -Process { $_ } -PipelineVariable currentName | ForEach-Object -Process {
            $filter, $message = if (![string]::IsNullOrWhiteSpace($currentName)) {
                "Name='$currentName'"
                $serverMessages.Error_Not_Found -f $currentName
            } else {
                $null
                $serverMessages.Error_None_Found
            }
            $instance = Get-CimInstance -Namespace root\MicrosoftBizTalkServer -ClassName MSBTS_Server -Filter $filter
            if ($null -eq $instance) {
                Write-Error -Message $message
                Write-Warning -Message $message
                $null
            } else {
                $instance
            }
        }
    }

    $arguments = @{ } + $PSBoundParameters
    $arguments.Remove('UserBoundParameters') | Out-Null
    if ($UserBoundParameters.ContainsKey('ErrorAction')) { $arguments.ErrorAction = $UserBoundParameters.ErrorAction }
    if ($UserBoundParameters.ContainsKey('WarningAction')) { $arguments.WarningAction = $UserBoundParameters.WarningAction }
    Enumerate-BizTalkServerCore @arguments
}

Import-LocalizedData -BindingVariable serverMessages -FileName Server.Messages.psd1