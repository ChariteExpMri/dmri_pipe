#!/bin/bash
# quality assessment/create screenshots
# vers. 18.11.24
# changed conda-initialization
#---------------------------------------------

# #########################################################################
#       QA using HPC without graphic support
# #########################################################################

#[OLD-version:]    eval "$(/opt/conda/bin/conda shell.bash hook)" # Conda initialization
source /etc/profile.d/conda.sh   # new Conda initialization


dirAnimal=$(ls -d */|head -n 1)
dirAnimalFP="$(pwd)/$dirAnimal"     ; #echo $dirAnimalFP ; #exit 1
dirMrtrix="$dirAnimalFP/mrtrix"
dirThis=$(pwd)


cd $dirMrtrix  # go into mrtrix-folder

screenshotmode=2  # [1]:python, [2]matlab

if [[ $screenshotmode -eq 1 ]]
    then
    echo "screenshot --python"
    #================================================================
    #======= switch conda-environment ##############
    echo "==switch to Pythonstuff-Conda-environment ==="
    conda activate /sc-projects/sc-proj-agtiermrt/Daten-2/condaEnvs/pythonstuff
    #conda info

    python ./../../../../shellscripts/makeScreenshot_densemap.py
    python ./../../../../shellscripts/makeScreenshot_famap.py

    echo "==switch back to default Conda-environment ==="
    conda activate /sc-projects/sc-proj-agtiermrt/Daten-2/condaEnvs/dtistuff
    #conda info

else
  echo "screenshot --matlab"
  module load scientific/matlab/R2021b
  path_scripts=./../../../../shellscripts
  matlab -nodisplay -nosplash -nodesktop -r "addpath('$path_scripts'); makeScreenshot_densemap('$dirMrtrix');makeScreenshot_famap('$dirMrtrix');exit;"
  #matlab -nodisplay -nosplash -nodesktop -r "cd ./../../../../shellscripts; makeScreenshot('$dirMrtrix');exit;"

fi

#================================================================
cd $dirThis # go back to entry-folder

echo "screenshots created"
