#!/bin/bash

###################################
# install script for bak-old.sh   #
# authored by github.com/kevinnls #
#   - another Linux user tired of #
#     type cp file file.bak       #
###################################

work_dir=/tmp/bak-old_installation/

debug(){ ### function to call when $DEBUG is set
    set -xv
}


### enable debugging if ###
${DEBUG+debug}       ###
### $DEBUG is set ###

# create dir for installation work

mkdir -p $work_dir
cd $work_dir

# cleanup

cd $HOME
rm -rf $work_dir