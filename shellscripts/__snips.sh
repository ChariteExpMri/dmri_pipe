#!/bin/bash
# preprocessing
# vers. 09.02.23 
#---------------------------------------------


# JUST SOME SNIPPETS::DO NOT EXECUTE


# ===========TEST =========================================

echo "here"
animalPath=$dirAnimal
echo "animal: $dirAnimalFP"


#for_each * : mrinfo  IN/mrtrix/dwi_den_unr_vox.mif -force -export_grad_fsl IN/mrtrix/bvecs_temp.txt IN/mrtrix/bvals_temp.txt

fileBval_temp=$dirAnimalFP/mrtrix/bvals_temp.txt
arrText=($(cat $fileBval_temp))

echo ${arrText[@]}
echo "---"
echo ${arrText[1]}
echo ${arrText[2]}
echo ${arrText[5]}

idx_zeroBval=""
for idx in "${!arrText[@]}"
do
	if [[  ${arrText[$idx]} = "0"  ]]; then
 	 echo "index & B-value: $idx -  ${arrText[$idx]}"
 	 
 	 if [ -z "$idx_zeroBval" ];then
       idx_zeroBval="$idx"
 	else
 	   idx_zeroBval="$idx_zeroBval,$idx"
 	fi
 fi
done
 echo "idx_zeroBval: '$idx_zeroBval'"
#mrconvert $dirAnimalFP/mrtrix/dwi_den_unr_vox.mif $dirAnimalFP/mrtrix/B0paired.nii -coord 3 $idx_zeroBval  -force
mrconvert $dirAnimalFP/mrtrix/dwi_den_unr_vox.mif $dirAnimalFP/mrtrix/B0paired.mif -coord 3 $idx_zeroBval  -force
mrinfo $dirAnimalFP/mrtrix/B0paired.mif -all


exit 

mrinfo $dirAnimalFP/mrtrix/dwi_den_unr_vox.mif -shell_bvalues
mrinfo $dirAnimalFP/mrtrix/dwi_den_unr_vox.mif -shell_sizes 
mrinfo $dirAnimalFP/mrtrix/dwi_den_unr_vox.mif -shell_indices 

shell_indices=$(mrinfo $dirAnimalFP/mrtrix/dwi_den_unr_vox.mif -shell_indices)
shell_sizes=$(mrinfo $dirAnimalFP/mrtrix/dwi_den_unr_vox.mif -shell_sizes)
shell_bvalues=$(mrinfo $dirAnimalFP/mrtrix/dwi_den_unr_vox.mif -shell_bvalues)

echo "shell_indices:$shell_indices"
echo "shell_sizes:$shell_sizes"
echo "shell_bvalues:$shell_bvalues"

indexBzero=${shell_bvalues%%0*}
echo ${#indexBzero}

mrinfo $dirAnimalFP/mrtrix/dwi_den_unr_vox.mif -all

#mrconvert $dirAnimalFP/mrtrix/dwi_den_unr_vox.mif slice.nii -coord 3 1:2:10  -force
#mrconvert $dirAnimalFP/mrtrix/dwi_den_unr_vox.mif full.nii  -force



ix_AVGTmask.nii