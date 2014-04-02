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

function check() {
  if [[ $? > 0 ]]; then
    lineno=$(expr ${BASH_LINENO} - 1)
    echo "ERROR line $lineno: $1"
    exit 1
  fi
}

# sync first

if [[ "$1" != "--fast" ]]; then
  repo sync
  check "Repo Sync Failed"
fi
export AUTO_TOP=`pwd`
repo forall '-ec' '
  cd $AUTO_TOP
  if [ $(grep "$REPO_PATH" .auto-merge_ignore) ]; then
    echo "WARNING: ignoreing $REPO_PROJECT"
    return 0
  fi
  if [ "$REPO_REMOTE" != "slimX" ]; then
    return 0
  fi
  cd $REPO_PATH
  echo "in $REPO_PATH"
  git branch -a | grep "aosp/master" > /dev/null
  if [ $? -gt 0 ]; then
    echo "ERROR: $REPO_PROJECT: does not have aosp/master"
    return 1
  fi
  git fetch aosp
  if [ $? -gt 0 ]; then
    echo "ERROR: $REPO_PROJECT: failed to fetch aosp/master"
    return 1
  fi
  git branch -a | grep "slimX/slim-master" > /dev/null
  if [ $? -gt 0 ]; then
    echo "ERROR: $REPO_PROJECT: does not have slimX/slim-master"
    return 1
  fi
  git checkout slim-master
  if [ $? -gt 0 ]; then
    echo "ERROR: $REPO_PROJECT: failed to checkout slimX/slim-master"
    return 1
  fi
  git pull slimX slim-master
  if [ $? -gt 0 ]; then
    echo "ERROR: $REPO_PROJECT: failed to pull slimX/slim-master"
    return 1
  fi
  git merge aosp/master -m "auto-merger: merge in from aosp/master"
  if [ $? -gt 0 ]; then
    echo "ERROR: $REPO_PROJECT: failed to merge in aosp/master"
    return 1
  fi
  git push -u slimX slim-master
  if [ $? -gt 0 ]; then
    echo "ERROR: $REPO_PROJECT: failed to push to slimX/slim-master"
    return 1
  fi
  echo "finished $REPO_PROJECT"
'

check "auto-merge failed, check log"
echo "all finished"
  
  