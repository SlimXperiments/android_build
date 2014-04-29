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
#   _println, check
# These variables must be assigned
#   remote, branch, slim_tools
#

#
# To disable colour, pass --nc
# To only sync slim, pass --slim
# To only sync master, pass --master
# To only push, pass --push
#

if [[ $(type printf) ]]; then
    function _println() {
        printf "%s\n" "$@"
    }
else
    function _println() {
        echo -e "${*}"
    }
fi

function _colour() {
  export CL_RED=$(tput setaf 1)
  export CL_GRN=$(tput setaf 2)
  export CL_ORG=$(tput setaf 3)
  export CL_BLU=$(tput setaf 4)
  export CL_MAG=$(tput setaf 5)
  export CL_CYN=$(tput setaf 6)
  export CL_RST=$(tput sgr0)
}

function check() {
    if [[ $? -gt 0 ]]; then
        lineno=$((BASH_LINENO - 1))
        _println "${CL_RED}ERROR line ${lineno}:${CL_RST} $1"
        exit 1
    fi
}

[[ "$@" != *--nc* ]] && _colour

[[ -z ${T} ]] && export T=${ANDROID_BUILD_TOP}
[[ -z ${T} ]] && [[ -f "build/envsetup.sh" ]] && export T=$(pwd)
[[ -z ${T} ]] && [[ -f "../../envsetup.sh" ]] && export T=$(readlink -f "$(pwd)/../../../")
if [[ -z ${T} ]]; then
    _println "${CL_RED}ERROR:${CL_RST} please run . build/envsetup.sh"
    exit 1
fi
export slim_tools="${T}/build/tools/slim"
export -f _println
export -f check


export remote="slimX"
export branch="slim-master"
if [[ "$@" == *--push* ]]; then
    args="${args} --push"
fi
if [[ "$@" == *--slim* ]]; then
    args="${args} --slim"
fi
if [[ "$@" == *--master* ]]; then
    args="${args} --master"
fi

repo forall -ec "bash '${slim_tools}/auto-merge-worker.sh' '${args}'"
check "process failed, check log"

_println "Process finished successfully"