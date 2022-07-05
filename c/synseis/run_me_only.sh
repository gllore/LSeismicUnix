#!/bin/bash

# see if global variable is set
# global variable LSeismicUnix locates main folder

 if [ -z "${LSeismicUnix}" ]; then

 	echo "global variable L_SU must first be set"
 	echo "e.g. in .bashrc: "
 	echo " export LSeismicUnix_script=/Location/of/script/folder "

fi

cd ${LSeismicUnix}/c/synseis
sh set_env_variables.sh
make synseis
