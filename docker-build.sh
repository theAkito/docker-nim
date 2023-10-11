#!/bin/bash
#########################################################################
# Copyright (C) 2020 Akito <the@akito.ooo>                              #
#                                                                       #
# This program is free software: you can redistribute it and/or modify  #
# it under the terms of the GNU General Public License as published by  #
# the Free Software Foundation, either version 3 of the License, or     #
# (at your option) any later version.                                   #
#                                                                       #
# This program is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the          #
# GNU General Public License for more details.                          #
#                                                                       #
# You should have received a copy of the GNU General Public License     #
# along with this program.  If not, see <http://www.gnu.org/licenses/>. #
#########################################################################
#
#################################   Boilerplate of the Boilerplate   ####################################################
# Coloured Echoes                                                                                                       #
function red_echo      { echo -e "\033[31m$@\033[0m";   }                                                               #
function green_echo    { echo -e "\033[32m$@\033[0m";   }                                                               #
function yellow_echo   { echo -e "\033[33m$@\033[0m";   }                                                               #
function white_echo    { echo -e "\033[1;37m$@\033[0m"; }                                                               #
# Coloured Printfs                                                                                                      #
function red_printf    { printf "\033[31m$@\033[0m";    }                                                               #
function green_printf  { printf "\033[32m$@\033[0m";    }                                                               #
function yellow_printf { printf "\033[33m$@\033[0m";    }                                                               #
function white_printf  { printf "\033[1;37m$@\033[0m";  }                                                               #
# Debugging Outputs                                                                                                     #
function white_brackets { local args="$@"; white_printf "["; printf "${args}"; white_printf "]"; }                      #
function echoDebug  { local args="$@"; if [[ ${debug_flag} == true ]]; then                                             #
white_brackets "$(white_printf   "DEBUG")" && echo " ${args}"; fi; }                                                    #
function echoInfo   { local args="$@"; white_brackets "$(green_printf  "INFO" )"  && echo " ${args}"; }                 #
function echoWarn   { local args="$@"; white_brackets "$(yellow_printf "WARN" )"  && echo " ${args}" 1>&2; }            #
function echoError  { local args="$@"; white_brackets "$(red_printf    "ERROR")"  && echo " ${args}" 1>&2; }            #
# Silences commands' STDOUT as well as STDERR.                                                                          #
function silence { local args="$@"; ${args} &>/dev/null; }                                                              #
# Check your privilege.                                                                                                 #
function checkPriv { if [[ "$EUID" != 0 ]]; then echoError "Please run me as root."; exit 1; fi;  }                     #
# Returns 0 if script is sourced, returns 1 if script is run in a subshell.                                             #
function checkSrc { (return 0 2>/dev/null); if [[ "$?" == 0 ]]; then return 0; else return 1; fi; }                     #
# Prints directory the script is run from. Useful for local imports of BASH modules.                                    #
# This only works if this function is defined in the actual script. So copy pasting is needed.                          #
function whereAmI { printf "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )";   }                     #
# Alternatively, this alias works in the sourcing script, but you need to enable alias expansion.                       #
alias whereIsMe='printf "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"'                            #
debug_flag=false                                                                                                        #
#########################################################################################################################
## Interactive Usage
##
### bash docker-build.sh
##
#
## Automatized Usage
##
### bash docker-build.sh        0.1.0             0.1.0              repo/image:0.1.0         true                             false
##                              ^~~~~             ^~~~~              ^~~~~~~~~~~~~~~~         ^~~~                             ^~~~~
##                              BUILD_VERSION     BUILD_REVISION     Complete Docker Tag      Build with "latest" tag, too?    Build multi-arch build with "buildx"?
#
build_version="$1"
build_revision="$2"
tag="$3"
latest="$4"
multiarch="$5"
current_time="$(date +'%Y-%m-%dT%H:%M:%S%Z')"
# Set to "false" if you want to automatize me.
interactive=true

if [[ $interactive == true ]]; then
  function describe {
    # Light grey output.
    printf '\033[38;5;250m%s%s%b\033[0m'  "==> " "$1" "\n"
  }
  function inputVerificationError {
    echoError "Please don't enter whitespace."
    white_echo "Try again..."
    echo
  }
  function askBuildVersion {
    yellow_echo "Build version:"
    describe "Presumably Docker tag version."
  }
  function askBuildRevision {
    yellow_echo "VCS revision tag:"
    describe "Can be same as build version."
  }
  function askDockerTag {
    yellow_echo "Docker tag:"
    describe "The whole tag like this:"
    describe "repo/image:version"
    describe "Version may match build version."
  }
  function askIfBuildAsLatestToo {
    yellow_echo "Build this image additionally with the tag \"latest\", as well? [Y/n]"
    describe "Confirm, if you want to build the latest image"
    describe 'with the current explicit version provided in the Docker tag'
    describe 'and with the "latest" tag, as well.'
  }
  function askMultiArchBuild {
    yellow_echo "Build this image with buildx for a multi-arch build? [y/N]"
    describe "Confirm, if you want build and push the latest image"
    describe 'as a multi-architectural build created with buildx.'
    describe 'This presumes you are already logged in through "docker login" with the correct account.'
    describe "This option assumes you know what you are doing and have already"
    describe 'successfully enabled the experimental "buildx" feature and already set up a builder, etc.'
    describe "Therefore, choose this option only if you know what you are doing."
    describe "Otherwise, deny this question."
  }
  askBuildVersion
  inputVerificationPattern='[[:space:]]|^$'
  while read -e input; do
    if ! [[ "${input}" =~ ${inputVerificationPattern} ]]; then
      build_version="$input"
      break
    else
      inputVerificationError
      askBuildVersion
    fi
  done
  askBuildRevision
  while read -e input; do
    if ! [[ "${input}" =~ ${inputVerificationPattern} ]]; then
      build_revision="$input"
      break
    else
      inputVerificationError
      askBuildRevision
    fi
  done
  askDockerTag
  while read -e input; do
    if ! [[ "${input}" =~ ${inputVerificationPattern} ]]; then
      tag="$input"
      break
    else
      inputVerificationError
      askDockerTag
    fi
  done
  askIfBuildAsLatestToo
  while read -e input; do
    case "${input}" in
      [Tt]rue|[Yy]|[Yy]es|'') latest=true; break ;;
      [Ff]alse|[Nn]|[Nn]o) latest=false; break ;;
      *) askIfBuildAsLatestToo; continue ;;
    esac
  done
  askMultiArchBuild
  while read -e input; do
    case "${input}" in
      [Tt]rue|[Yy]|[Yy]es) multiarch=true; break ;;
      [Ff]alse|[Nn]|[Nn]o|'') multiarch=false; break ;;
      *) askMultiArchBuild; continue ;;
    esac
  done
  unset -f describe
  unset -f inputVerificationError
  unset -f askBuildVersion
  unset -f askBuildRevision
  unset -f askDockerTag
  unset -f askIfBuildAsLatestToo
fi

if [[ -z "${build_version}" ]]; then
  echoError "No version provided."
  echoError "Provide the new Docker tag version as the first argument to $0."
  exit 1
fi

if [[ -z "${build_revision}" ]]; then
  echoError "No VCS revision tag provided."
  echoError "Provide the current VCS revision tag as the second argument to $0."
  exit 1
fi

if [[ -z "${tag}" ]]; then
  echoError "No Docker tag provided."
  echoError "Provide the entire Docker tag as the third argument to $0."
  exit 1
fi

if [[ -z "${latest}" ]]; then
  echoError 'Not declared, if build with "latest" tag is requested.'
  echoError "Provide a \"Yes\" or \"No\" as the fourth argument to $0."
  exit 1
fi

if [[ -z "${multiarch}" ]]; then
  echoError 'Not declared, if multiarch build with "buildx" is requested.'
  echoError "Provide a \"Yes\" or \"No\" as the fifth argument to $0."
  exit 1
fi

function dockerBuild {
  if [[ "$1" == "latest" ]]; then
    tag="$(printf '%s%s' "${tag%:*}" ":latest")"
  fi
  docker build \
    --build-arg BUILD_VERSION=$build_version \
    --build-arg BUILD_REVISION=$build_revision \
    --build-arg BUILD_DATE=$current_time \
    --force-rm \
    --tag "${tag}" \
    --file Dockerfile \
    .
}

function dockerBuildx {
  if [[ "$1" == "latest" ]]; then
    tag="$(printf '%s%s' "${tag%:*}" ":latest")"
  fi
  docker buildx build \
    --build-arg BUILD_VERSION=$build_version \
    --build-arg BUILD_REVISION=$build_revision \
    --build-arg BUILD_DATE=$current_time \
    --force-rm \
    --platform linux/arm/v7,linux/arm64/v8,linux/amd64 \
    --push \
    --tag "${tag}" \
    --file Dockerfile \
    .
}

if   [[ $multiarch == false ]]; then
  dockerBuild
  if [[ $latest == true ]]; then
    dockerBuild latest
  fi
elif [[ $multiarch == true ]]; then
  dockerBuildx
  if [[ $latest == true ]]; then
    dockerBuildx latest
  fi
fi