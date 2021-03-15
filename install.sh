#!/bin/bash

###################################
# install script for bak-old.sh   #
# authored by github.com/kevinnls #
#   - another Linux user tired of #
#     type cp file file.bak       #
###################################

set -e

VERSION='v0.1.0-beta'
work_dir=/tmp/bak-old_installation/
download_url="https://github.com/kevinnls/bak-old/releases/download/${VERSION}/bak-old.sh"

# list of known downloaders and options for download
declare -A dlers
dlers[curl]="curl -fsSLO"
dlers[wget]="wget -q"
# list of possible destinations for root user
r_dstdirs=('/usr/local/bin' 
			'/usr/bin' 
			'/bin')
# list of possible destinations for normal user
u_dstdirs=("$HOME/.local/bin"
			"$HOME/bin")

declare downloader
declare dest_dir

debug(){ ### function to call when $DEBUG is set
    set -xv
}

is_command(){ ### function to check if a command exists
	{ command -v $1;} >/dev/null && return 0 || return 1
}

err_no_downloader(){
	cat <<- EOM
	$(tput setaf 1; tput bold)ERR: missing dependencies$(tput sgr0)

	required by this installation script:
	    - wget OR curl
	install either application using your package manager and try again

	alternatively, you can manually download the file from
	    $download_url
	to a directory in your PATH

	EOM
	exit 1
}
err_no_dest_in_path(){
	cat <<-EOM
	$(tput setaf 1; tput bold)ERR: no preconfigured destinations are in \
	your PATH$(tput sgr0)
	check your PATH variable configuration
	#or specify the destination with -d

	EOM
	exit 1
}
err_no_home_dir(){
	cat <<- EOM
	$(tput setaf 1; tput bold)ERR: user $(whoami) does not have a valid home \
	directory

	EOM
	exit 1
}

find_dler(){
	for dler in ${!dlers[@]}; do
		is_command $dler && downloader="${dlers[$dler]}"
		[[ -n "$downloader" ]] && return
	done

	[[ -z "$downloader" ]] && err_no_downloader
}

find_dest_dir(){
	local user_id=$(id -u)
	local dirlist
	if [[ user_id -eq 0 ]]; then
		dirlist=(${r_dstdirs[@]})
	elif [[ -d "$HOME" ]]; then
		dirlist=(${u_dstdirs[@]})
	else
		err_no_home_dir
	fi
			
	for dir in ${dirlist[@]}; do
		if [[ "$PATH" =~ /*:${dir}* ]] || [[ "$PATH" =~ /*${dir}:* ]]; then
			dest_dir="$dir"
		fi
		[[ -n "$dest_dir" ]] && return
	done

	[[ -z "$dest_dir" ]] && err_no_dest_in_path
}

setup() {
	# setup
	# create temp dir for installation work
	mkdir -p "$work_dir"
	cd "$work_dir"
}

cleanup(){
	# cleanup
	cd "$HOME"
	rm -rf "$work_dir"
}

install(){
	setup
	find_dler
	echo $downloader
	find_dest_dir
	echo $dest_dir
	cleanup
}

### enable debugging if ###
${DEBUG+debug}       ###
### $DEBUG is set ###

install