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

ConvertFrom-StringData @'
Info_Creating=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' is being created...
Info_Created=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' has been created.
Info_Disabling=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' is being disabled...
Info_Disabled=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' has been disabled.
Info_Enabling=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' is being enabled...
Info_Enabled=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' has been enabled.
Info_Existing=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' already exists.
Info_Removing=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' is being removed...
Info_Removed=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' has been removed.
Info_Restart_Unnecessary=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' is not running and does not need to be restarted.
Info_Restarting=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' is being restarted...
Info_Restarted=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' has been restarted.
Info_Starting=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' is being started...
Info_Started=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' has been started.
Info_Stopping=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' is being stopped...
Info_Stopped=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' has been stopped.

Error_Create=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' could not be thoroughly created. Attempt will be made to clean up partially created objects.
Error_None_Found=Could not find any Microsoft BizTalk Server Host Instance.
Error_None_Found_On_Server=Could not find any Microsoft BizTalk Server Host Instance on Server '{0}'.
Error_Not_Found_On_Any_Server=Could not find Microsoft BizTalk Server Host Instance '{0}' on any server.
Error_Not_Found=Could not find Microsoft BizTalk Server Host Instance '{0}' on Server '{1}'.
Error_State=Microsoft BizTalk Server Host Instance '{0}' on Server '{0}' is not in the expected state.
Error_Remove=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' could not be thoroughly removed.

Should_Create=Create Host Instance '{0}' on Server '{1}'
Should_Disable=Disable Host Instance '{0}' on Server '{1}'
Should_Enable=Enable Host Instance '{0}' on Server '{1}'
Should_Remove=Remove Host Instance '{0}' on Server '{1}'
Should_Restart=Restart Host Instance '{0}' on Server '{1}'
Should_Start=Start Host Instance '{0}' on Server '{1}'
Should_Stop=Stop Host Instance '{0}' on Server '{1}'

Warn_Start_Disabled=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' is disabled and cannot be started.
Warn_Start_Stop_Isolated=Microsoft BizTalk Server Host Instance '{0}' on Server '{1}' is an Isolated Host and can neither be started nor stopped.
'@
