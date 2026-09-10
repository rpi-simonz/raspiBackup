#!/bin/bash
#######################################################################################################################
#
# Script to download and install the raspiBackup package
#
# Visit http://www.linux-tips-and-tricks.de/raspiBackup for latest code and other details
#
#######################################################################################################################
#
#    Copyright (c) 2026 framp at linux-tips-and-tricks dot de
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#######################################################################################################################

LOG_FILE=$(cut -d'.' -f1 <<< "$(basename "$0")").log
readonly LOG_FILE

# REPO_OWNER=framps
# BRANCH=master
REPO_OWNER=rpi-simonz
BRANCH=m_972
readonly REPO_OWNER
readonly BRANCH

# GITHUB_URL="https://raw.githubusercontent.com/${REPO_OWNER}/raspiBackup/refs/heads/${BRANCH}/build/deb"
# GITHUB_URL="https://github.com/rpi-simonz/raspiBackup/raw/refs/heads/m_972/build/deb"
GITHUB_URL="https://github.com/${REPO_OWNER}/raspiBackup/blob/refs/heads/${BRANCH}/build/deb"

readonly GITHUB_URL

function err() {
    local rc="$1"
    echo "??? Unexpected error occured with RC $rc"
    local i=0
    local FRAMES=${#BASH_LINENO[@]}
    for ((i = FRAMES - 2; i >= 0; i--)); do
        echo '  File' \""${BASH_SOURCE[i + 1]}"\", line ${BASH_LINENO[i]}, in "${FUNCNAME[i + 1]}"
        sed -n "${BASH_LINENO[i]}{s/^/    /;p}" "${BASH_SOURCE[i + 1]}"
    done
    exit 42
}

cleanup() {
	rm -f ${REPO_OWNER}.gpg.asc
	# rm -f raspiBackup.deb
	# rm -f raspiBackup.deb.sig
	if (( $1 == 0 )); then
		: rm -f "$LOG_FILE"
	else
		echo "??? Installation failed"
		echo "!!! Check $LOG_FILE for details"
	fi
}

trap 'err $?' ERR
trap 'cleanup $?' SIGINT SIGTERM SIGHUP EXIT

# enable logging
exec 1> >(stdbuf -i0 -o0 -e0 tee -ia "$LOG_FILE")
exec 2> >(stdbuf -i0 -o0 -e0 tee -ia "$LOG_FILE" >&2)

rm -f "$LOG_FILE"

if [[ -n $1 && -d "$1" ]]; then

	cd "$1" || exit
	if [[ ! -f "raspiBackup.deb" ]]; then
		echo "??? $1/raspiBackup.deb not found"
		exit 42
	fi
	if [[ ! -f "raspiBackup.deb.sig" ]]; then
		echo "??? $1/raspiBackup.deb.sig not found"
		exit 42
	fi
else
	echo "--- Downloading raspiBackup Debian package from github.com/${REPO_OWNER}"
	curl -fsSLO "$GITHUB_URL/raspiBackup.deb"
	curl -fsSLO "$GITHUB_URL/raspiBackup.deb.sig"
fi

#version=$(dpkg -I raspiBackup.deb | grep "^ Version" | cut -f 3 -d ' ')

:<<"SKIP"
echo -n "--- Installing raspiBackup $version. Are you sure? (y|N) "

read -r -n 1 answer

if [[ -n "${str//[[:space:]]/}" ]]; then
	echo
fi

if [[ ! $answer =~ [yYjJ] ]]; then
	echo "!!! Installation of raspiBackup $version aborted"
	exit 0
fi
SKIP

# retrieve and import ${REPO_OWNER} gpg key from github if it doesn't exist already in keyring
if ! gpg --list-keys | grep -q ${REPO_OWNER}; then
	echo "--- Retrieving ${REPO_OWNER} key from github"
	curl https://github.com/${REPO_OWNER}.gpg | gpg --yes --dearmor -o ${REPO_OWNER}.gpg.asc
	echo "--- Importing ${REPO_OWNER} key"
	gpg --import  ${REPO_OWNER}.gpg.asc
fi

echo "--- Verifying Debian package was created by repo owner (usually framp)"
# will fail with unexpected error if verification fails
gpg --verbose --verify raspiBackup.deb.sig raspiBackup.deb

echo "--- Installing raspiBackup package and all dependencies"
sudo apt-get install --allow-downgrades -y ./raspiBackup.deb | tee -a "$LOG_FILE" 2>&1

dpkg --list | grep raspibackup | awk '{ print "--- raspiBackup", $3, "installed successfully"; }'

