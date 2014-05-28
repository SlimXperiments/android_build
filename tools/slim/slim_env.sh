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

function _check() {
    if [[ $? -gt 0 ]]; then
        lineno=$((BASH_LINENO - 1))
        _println "${CL_RED}ERROR line ${lineno}:${CL_RST} $1"
        exit 1
    fi
}

export -f _println
export -f _colour
export -f _check