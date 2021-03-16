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
tmp_file_path="$work_dir/bak-old.sh"
download_url="https://github.com/kevinnls/bak-old/releases/download/${VERSION}/bak-old.sh"

# list of known downloaders and options for download
declare -A dlers
dlers[curl]="curl -fsSLRo $tmp_file_path"
dlers[wget]="wget -qO $tmp_file_path"
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

# text formatting escape sequences
txt_bold='\e[1m'
txt_red='\e[31m'
txt_green='\e[32m'
txt_yellow='\e[33m'
txt_0='\e[0m'

err_no_downloader(){
	echo -e "$(cat <<- EOM
	${txt_bold}${txt_red}ERR: missing dependencies${txt_0}

	required by this installation script:
	    - wget OR curl
	install either application using your package manager and try again

	alternatively, you can manually download the file from
	    $download_url
	to a directory in your PATH

	EOM
	)"
	exit 1
}
err_no_dest_in_path(){
	echo -e "$(cat <<-EOM
	${txt_bold}${txt_red}ERR: no preconfigured destinations are in your PATH${txt_0}
	check your PATH variable configuration
	or specify the destination with -d

	EOM
	)"
	exit 1
}
err_no_home_dir(){
	echo -e "$(cat <<- EOM
	${txt_bold}${txt_red}ERR: $(whoami) does not have a valid home directory${txt_0}

	EOM
	)"
	exit 1
}
err_unknown(){
	echo -e "$(cat <<-EOM
	${txt_bold}${txt_red}ERR: some unhandled error has occurred${txt_0}
	
	EOM
	)"
	exit 1
}
install_success(){
	echo -e "$(cat <<-EOM
	${txt_bold}${txt_green}SUCCESS: bak-old.sh has been installed successfully${txt_0}
	EOM
	)"
	bak-old.sh -h
	exit 0
}
install_failure(){
	echo -e "$(cat <<-EOM
	${txt_bold}${txt_green}FAILUR: failed to install bak-old.sh :(${txt_0}
	EOM
	)"
	exit 127
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
	elif [[ ! -d "$HOME" ]]; then
		err_no_home_dir
	else
		err_unknown
	fi
			
	for dir in ${dirlist[@]}; do
		if [[ "$PATH" =~ /*:${dir}* ]] || [[ "$PATH" =~ /*${dir}:* ]]; then
			dest_dir="$dir"
		fi
		[[ -n "$dest_dir" ]] && return
	done

	[[ -z "$dest_dir" ]] && err_no_dest_in_path
}

download(){
	$downloader $download_url
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
	exit ${1-0}
}

trap "cleanup 1" SIGHUP SIGINT SIGTERM ERR

install(){
	setup
	find_dler
	find_dest_dir
	download
	chmod 755 "$tmp_file_path"
	mv "$tmp_file_path" "${dest_dir}/"
	is_command bak-old.sh && install_success || install_failure
}

### enable debugging if ###
${DEBUG+debug}       ###
### $DEBUG is set ###

install