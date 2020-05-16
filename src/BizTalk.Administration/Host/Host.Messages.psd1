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
Info_Creating={0} Microsoft BizTalk Server Host '{1}' is being created...
Info_Created={0} Microsoft BizTalk Server Host '{1}' has been created.
Info_Existing={0} Microsoft BizTalk Server Host '{1}' already exists.
Info_Removing=Microsoft BizTalk Server Host '{0}' is being removed...
Info_Removed=Microsoft BizTalk Server Host '{0}' has been removed.

Error_None_Found=Could not find any Microsoft BizTalk Server Host.
Error_Not_Found=Could not find Microsoft BizTalk Server Host '{0}'.
Error_Type=Microsoft BizTalk Server Host '{0}' is not of the expected type.

Should_Create=Create {0} Host '{1}'
Should_Remove=Remove Host '{0}'

Warn_Existing_Different_Type=A Microsoft BizTalk Server Host '{0}' of a different type already exists.
'@
