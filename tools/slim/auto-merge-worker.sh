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

# note that this script relies on a wrapper, do not run this directly
#
# Required functions:
#   _println, check
# Required Variables:
#   remote, branch, slim_tools
#

[[ "${REPO_REMOTE}" != "${remote}" ]] && exit 0

function colourise() {
    export repo_path="${CL_BLU}${REPO_PATH}${CL_RST}"
    export repo_project="${CL_BLU}${REPO_PROJECT}${CL_RST}"
}

function fetch() {
    ignore=($(grep "^${REPO_PATH}" "${slim_tools}/.auto-merge_ignore"))
    if [ -n "${ignore[*]}" ]; then
        if [[ "${ignore[1]}" == "${1}" ||  "${ignore[1]}" == "" ]]; then
            _println "${CL_ORG}WARNING:${CL_RST} ignoring ${repo_project}"
            exit 0
        fi
    fi

    git branch -a | grep "${2}/${3}" > /dev/null
    check "${repo_project}: does not have ${2}/${3}"
    
    git branch -a | grep "${remote}/${branch}" > /dev/null
    check "${repo_project}: does not have ${remote}/${branch}"

    git fetch "${2}"
    check "${repo_project}: failed to fetch ${2}"
    
    [[ $(git log ${2}/${3} ^${branch}) ]] || exit 0

    _println "${CL_CYN}merging ${CL_RST} ${repo_path}"

    git checkout "${branch}"
    check "${repo_project}: failed to checkout ${remote}/${branch}"
    
    git pull "${remote}" "${branch}"
    check "${repo_project}: failed to pull ${remote}/${branch}"
    
    git merge "${2}/${3}" -m "auto-merger: merge in from ${2}/${3}"
    check "${repo_project}: failed to merge in ${2}/${3}"
    
    _println "${CL_GRN}merged${CL_RST} ${repo_project}"
}

function push() {
    ignore=($(grep "^${REPO_PATH}" "${slim_tools}/.auto-merge_ignore"))
    [[ -n "${ignore[0]}" ]] && [[ -z "${ignore[1]}" ]] && exit 0

    [[ $(git log ${branch}  ^${remote}/${branch}) ]] || exit 0

    _println "${CL_CYN}pushing${CL_RST} ${repo_path}"

    git push -u "${remote}" "${branch}"
    check "${repo_project}: failed to push to ${remote}/${branch}"
    
    _println "${CL_GRN}pushed${CL_RST} ${repo_project}"
}

colourise  # does nothing if colours are not defined
if [[ "$@" == *--slim* ]]; then
    fetch "slim" "github" "kk4.4"
    check "Slim: could not finish"
fi
if [[ "$@" == *--master* ]]; then
    fetch "master" "aosp" "master"
    check "Master: could not finish"
fi
if [[ "$@" == *--push* ]]; then
    push
    check "push failed, check log"
fi
if [[ "$@" == "" ]]; then
    _println "${CL_RED}WARNING:${CL_RST} Nothing to do. Bailing"
    exit 1
fi

_println "${CL_GRN}finished${CL_RST} ${repo_project}"