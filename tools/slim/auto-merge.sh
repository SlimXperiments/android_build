#!/bin/bash
#
# Copyright 2014 SlimRoms
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# before using this script, the aosp branches must be set up for merging.
# place in the root of the workspace, then run
# it is recommended you configure ~/.netrc while running this script
# machine github.com
#   login <username>
#   password <password>

#
# This script is a wrapper script for the main merge worker
# If you intend on bypassing this script, then these functions must be defined first:
#   _println, _check
# These variables must be assigned
#   remote, branch, slim_tools
#

#
# To disable colour, pass --nc
# To only sync slim, pass --slim
# To only sync master, pass --master
# To only push, pass --push
#

[[ -z ${T} ]] && T=${ANDROID_BUILD_TOP}
[[ -z ${T} ]] && [[ -f "build/envsetup.sh" ]] && T=$(pwd)
[[ -z ${T} ]] && [[ -f "../../envsetup.sh" ]] && T=$(readlink -f "$(pwd)/../../../")
if [[ -z ${T} ]]; then
    echo "ERROR: please run . build/envsetup.sh"
    exit 1
fi
export slim_tools="${T}/build/tools/slim"

. "${slim_tools}/slim_env.sh"

[[ "$@" != *--nc* ]] && _colour

export remote="slimX"
export branch="slim-master"
_println "$@"

repo forall -ec "bash '${slim_tools}/auto-merge-worker.sh' '${@}'"
_check "process failed, check log"

_println "Process finished successfully"