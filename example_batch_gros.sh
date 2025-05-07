#!/bin/bash
#SBATCH --job-name=gros        #Specify job name
#SBATCH --output=gros.o%A_%a        #FileName of output with %A(jobID) and %a(array-index);(alternative: .o%j)
#SBATCH --error=gros.e%A_%a         #FileName of error with %A(jobID) and %a(array-index);alternative: .e%j)

#SBATCH --partition=compute         # Specify partition name
#SBATCH --nodes=1                   # Specify number of nodes
#SBATCH --cpus-per-task=100         # Specify number of CPUs (cores) per task
#SBATCH --time=48:00:00             # Set a limit on the total run time; example: 22:00:00(22hours) or 7-00(7days)
#SBATCH --array=1-12                # Specify array elements (indices), i.e. indices of of parallel processed dataSets  

#eval "$(/opt/conda/bin/conda shell.bash hook)" # Conda initialization in the bash shell
source /etc/profile.d/conda.sh                 # Conda.ini in bash shell
conda activate /sc-projects/sc-proj-agtiermrt/Daten-2/condaEnvs/dtistuff        # Activate conda virtual environment


animalID=$(printf "%03d" $SLURM_ARRAY_TASK_ID)                #obtain SLURM-array-ID 
cd /sc-projects/sc-proj-agtiermrt/Daten-2/Imaging/dwi/gros_LAERMRT/data/a$animalID
./../../shellscripts/run_mrtrix.sh


# ====================================================
#   INFOS:    DIRS   &   ANIMAL NAMES   
# ====================================================
# ___ animal [a001]: "20200930MG_LAERMRT_MGR000023" ___
# ___ animal [a002]: "20201013MG_LAERMRT_MGR000040" ___
# ___ animal [a003]: "20201104MG_LAERMRT_MGR000073" ___
# ___ animal [a004]: "20210208MG_LAERMRT_MGR000080" ___
# ___ animal [a005]: "20210607MG_LAERMRT_MGR000143" ___
# ___ animal [a006]: "20210608MG_LAERMRT_MGR000141" ___
# ___ animal [a007]: "20220329MG_LAERMRT_MGR000207" ___
# ___ animal [a008]: "20220421MG_LAERMRT_MGR000224" ___
# ___ animal [a009]: "20220428MG_LAERMRT_MGR000185" ___
# ___ animal [a010]: "20220505MG_LAERMRT_MGR000234" ___
# ___ animal [a011]: "20220523MG_LAERMRT_MGR000196" ___
# ___ animal [a012]: "20220525MG_LAERMRT_MGR000208" ___
