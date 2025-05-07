#!/bin/bash
# main calling script
# vers. 09.02.23 
# ----------------------------------------
# "config.txt" defines the species (rat or mouse) and used DWI-files
#---------------------------------------------

basepath=$(dirname $0)
workdir="$(basename $(pwd))"

#---------- message: start processing of this animal ---------------------------------
echo " "
echo "$(tput setaf 0)$(tput setab 5) =================================================================== $(tput sgr 2) [$workdir]  $(tput sgr 0) "
echo "$(tput setaf 0)$(tput setab 5) #START-PROCESSING $(tput setab 3)$(tput sgr 2)   [$workdir]    $(tput setaf 3)$(tput setab 0)  $(date)  $(tput sgr 0) "
SECONDS=0






# PREPROCESSING ____________________________________________________________________________________________
if [ 1 -eq 1 ]; then
  echo "[1] PREPROCESSING"
  ./$basepath/trafo2standardspace.sh
fi

#exit 0






