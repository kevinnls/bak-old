#!/bin/bash

###################################
# authored by github.com/kevinnls #
#   - another Linux user tired of #
#     type cp file file.bak       #
###################################

### IFS precautions
OLDIFS="$IFS"
unset IFS

### parse parameters
# file names
# `-d` dest dir
# `-b | -o` mode: cloned file suffix
# ` ` follow symlinks
# ` ` lightweight copies

print_usage(){
cat << HERE
$(tput bold; tput setaf 3)${0##*/}$(tput sgr0)
    Create copies of files with .bak or .old suffixes
$(tput bold)USAGE$(tput sgr0)
    $(tput bold)${0##*/}$(tput sgr0) [-b|o] FILES [ -d DESTINATION ]

$(tput bold)OPTIONS$(tput sgr0)
  Suffix for FILES -- only one can be used
    -b	$(tput bold).bak$(tput sgr0) [default]
    -o	$(tput bold).old$(tput sgr0)
  Destination for clones
    -d	\`cp FILES DESTINATION/FILES.suffix\`
HERE
}

set_dest(){
    dest=$1
}
set_mode(){
    if [[ -z $mode ]]; then
	mode=$1
    else
	inexclusive_flags
    fi
}
add_file(){
    files=("${files[@]}" "$1")
}

parse_combined(){

    combi=${1/-/}

    in_combi(){
	[[ "$combi" =~ [:alnum:]*($1){1}[:alnum:]* ]]
    }
    un_combi(){
	combi=${combi/$1/}
    }

    if in_combi 'b';then
       set_mode bak
       un_combi 'b'
    fi
    if in_combi 'o'; then
       set_mode old
       un_combi 'o'
    fi

    [[ "$combi" =~ [:alnum:]*(d){1} ]] && set_dest $2 && ret=2

    if [[ -z "$combi" ]]; then
	return ${ret:-1} #return number of positions to shift
    else
	tput setaf 1
	echo "ERROR: unrecognised flags"
	tput sgr0
	print_usage
	exit 1
    fi
}

inexclusive_flags(){
    echo "modes backup and old cannot co-exist"
    exit
}

while [[ $# -gt 0 ]]; do
    case $1 in
	'-h' )
	    print_usage
	    exit 0
	    ;;
	'-d' )
	    set_dest "$2"
	    shift 2
	    ;;
	'-b' )
	    set_mode bak
	    shift 1
	    ;;
	'-o' )
	    set_mode old
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

echo params sanitised
echo files: ${files[@]}
echo mode: $mode
echo dest: $dest

### reset IFS
IFS="$OLDIFS"
