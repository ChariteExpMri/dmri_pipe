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




#./$basepath/test4.sh
#exit 0




# PREPROCESSING ____________________________________________________________________________________________
if [ 1 -eq 1 ]; then
  echo "[1] PREPROCESSING"
  ./$basepath/preproc.sh
fi


# tensor metrics ____________________________________________________________________________________________
if [ 1 -eq 1 ]; then
  echo "[2] TENSOR-METRICS"
  ./$basepath/tensorMetrics.sh
fi

# connectome ____________________________________________________________________________________________
if [ 1 -eq 1 ]; then
  echo "[3] CONNECTOME"
  ./$basepath/connectome.sh
fi

# TVB (obtain data for the virtual brain) _____________________________________________________________________
if [ 1 -eq 1 ]; then
  echo "[4] OBTAIN DATA FOR THE VIRTUAL BRAIN"
  ./$basepath/virtualbrain.sh
fi

#  TRAFO TO TO STANDARD-SPACE (SS) _________________________________________________________________________
if [ 1 -eq 1 ]; then
  echo "TRAFO TO STANDARD-SPACE (SS)"
  ./$basepath/trafo2standardspace.sh
fi
#  QA on HPC ____________________________________________________________________________________________
if [ 1 -eq 1 ]; then
  echo "QA on HPC"
  ./$basepath/qa_HPC.sh
fi



# quality assesment ____________________________________________________________________________________________
#if [ 1 -eq 1 ]; then
#  #QA is not done on our HPC-cluster (no graphics support)...thus QA is not done here (but after processing via the old linux system) 
#  echo "[5] QULAITY ASSESSMENT not performed yet!!!"
#  #./$basepath/qa.sh
#fi




#---------- message: finished of animal with processing-time---------------------------------
dt=$(printf '[dT] %dh:%dm:%ds\n' $(($SECONDS/3600)) $(($SECONDS%3600/60)) $(($SECONDS%60)) )
#echo "dT: $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
printf "$(tput setaf 0)$(tput setab 4) #PROCESSING FINISHED $(tput setab 3)$(tput sgr 2)   [$workdir]  $(tput setaf 3)$(tput setab 0) $(date) $(tput setaf 4)$(tput setab 0) $(tput setab 0) $dt $(tput sgr 0) \n"


