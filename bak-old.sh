#!/bin/bash

###################################
# authored by github.com/kevinnls #
#   - another Linux user tired of #
#     type cp file file.bak       #
###################################
version='0.1.0-beta'

### IFS precautions	#
OLDIFS="$IFS"
unset IFS
### error precautions
set -e				
#####################

debug(){ ### function to call when $DEBUG is set
    set -xv
}

###############################################################################
# f() FOR PRINTING PROMPTS
#############################
print_usage(){
    cat << HERE
$(tput bold; tput setaf 3)${0##*/}$(tput sgr0)
    Create copies of files with .bak or .old suffixes
$(tput bold)USAGE$(tput sgr0)
    $(tput bold)${0##*/}$(tput sgr0) [-b|o] [-0|1] [-r] FILES [ -d DESTINATION ]

$(tput bold)OPTIONS$(tput sgr0)
  Suffix for FILES -- only one can be used
    -b	$(tput bold).bak$(tput sgr0) [default]
    -o	$(tput bold).old$(tput sgr0)

  Destination for clones
    -d	save the clones in DESTINATION
       [default] is the current directory

  Lightweight copies
    -0  create if possible [default]
    -1  force regular copies

  Recursive clone
    -r  clone a directory and its contents
HERE
}

print_version(){
    cat << HERE
$(tput bold)${0##*/}: v${version}$(tput sgr0)
    by https://github.com/kevinnls
HERE
}

print_err(){
    tput setaf 1
    case $1 in
        bo)
            echo "ERROR: modes backup and old cannot co-exist"
            ;;
        01)
            echo "ERROR: lightweight copy modes cannot co-exist"
            ;;
        x)
            echo "ERROR: unrecognised flags"
            tput sgr0
            print_usage
            ;;
        *)
            echo "UNKNOWN ERROR"
    esac
    tput sgr0
    exit 1
}

copy_succ(){
    echo " ✅ $(tput setaf 2; tput bold)${1}.${2:-bak}$(tput sgr0)"
}
copy_fail(){
    echo " ❌ $(tput setaf 1; tput bold)${1}$(tput sgr0)"
}
copy_nofile(){
    echo " ❌ $(tput setaf 1; tput bold)${1}$(tput sgr0) : file does not exist"
}

###############################################################################
# f() FOR SETTING OPTIONS
############################
set_dest(){
    if [[ -n "$1" ]]  && ! realpath -e "$1" >/dev/null 2>&1 ;then
        echo $1 does not exist
        echo creating now...
        mkdir -p $(realpath "$1")
        [[ $? -ne 0 ]] && exit 1
    fi
    dest=$(realpath "$1")
}
set_mode(){
    if [[ -z $mode ]]; then
        mode=$1
    else
        print_err 'bo'
    fi
}
set_weight(){
    if [[ -z "$weight" ]]; then
        weight="$1"
    else
        print_err '01'
    fi
}
add_file(){
    files=("${files[@]}" "$1")
}

###############################################################################
# f() FOR PARSING PARAMS AND OPTIONS
#######################################

in_combi(){
    [[ "$combi" =~ [:alnum:]*($1){1}[:alnum:]* ]]
}
un_combi(){
    combi=${combi/$1/}
}

parse_combined(){

    combi="${1/-/}"

    if in_combi 'b';then
        set_mode bak
        un_combi 'b'
    fi
    if in_combi 'o'; then
        set_mode old
        un_combi 'o'
    fi
    if in_combi '0'; then
        set_weight 'auto'
        un_combi '0'
    fi
    if in_combi '1'; then
        set_weight 'never'
        un_combi '1'
    fi

    [[ "$combi" =~ [:alnum:]*(d){1} ]] && set_dest $2 && ret=2
        # setting return value to 2 to shift 2 in caller
        # in case of -d <dest>

    if [[ -z "$combi" ]]; then
        return ${ret:-1}
    else
        print_err 'x'
        exit 1
    fi
}

### enable debugging ###
${DEBUG+debug}       ###
### if $DEBUG is set ###

###############################################################################
# SANITISING PARAMS AND OPTIONS
##################################
while [[ $# -gt 0 ]]; do
    case $1 in
    '-h' )
        print_usage
        exit 0
        ;;
    '-v' )
        print_version
        exit 0
        ;;
    '-r' )
        recurse='-r' #set_recurse
        shift 1
        ;;
    '-d' )
        set_dest "$2"
        shift 2
        ;;
    '-b' )
        set_mode 'bak'
        shift 1
        ;;
    '-o' )
        set_mode 'old'
        shift 1
        ;;
    '-0' )
        set_weight 'auto'
        shift 1
        ;;
    '-1')
        set_weight 'never'
        shift 1
        ;;
    -* )
        parse_combined "$1" "$2"
        shift $?
        ;;
    * )
        add_file "$1"
        shift 1
        ;;
    esac
done


###############################################################################
# THE ACTUAL COPYING CODE
############################
for file in "${files[@]}"; do
    if realpath -e "$file" >/dev/null 2>&1 ;then

        src_filepath="$(realpath "$file")"
        dst_filepath="${dest:-${src_filepath%/*}}"
        dst_filename="${src_filepath##*/}.${mode:-bak}"
        cp_weight="--reflink=${weight:-auto}"

        cp ${recurse} ${cp_weight} "$src_filepath" "$dst_filepath/$dst_filename"
        [[ $? -eq 0 ]] && copy_succ $file $mode || copy_fail $file

    else
        copy_nofile $file
    fi
done

### reset IFS###
IFS="$OLDIFS"  #
################
