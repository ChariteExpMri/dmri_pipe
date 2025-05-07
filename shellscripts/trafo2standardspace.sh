#!/bin/bash
# transformation to standard space
# vers. 8.5.24
#---------------------------------------------




dirAnimal=$(ls -d */|head -n 1)
dirAnimalFP="$(pwd)/$dirAnimal"     ; #echo $dirAnimalFP ; #exit 1
dirMrtrix="$dirAnimalFP/mrtrix"
dirThis=$(pwd)
#echo $dirAnimalFP
#echo $dirMrtrix








cd $dirMrtrix  # go into mrtrix-folder
#================================================================
# get rigid registration from DWI-space to native space (NS)
mrregister ./../t2.nii rc_t2.mif -type rigid -rigid_niter 10000 -rigid trafo_NS2DWI.txt -force

# make smaller tck-file for QA
tckedit 100k.tck -number 10k 10k.tck -force

# transform tck-file to NS
warpinit ./../t2.nii w_i.mif -force
transformcompose w_i.mif trafo_NS2DWI.txt warpfield_NS.mif -template ./../t2.nii -force
tcktransform 10k.tck warpfield_NS.mif 10k_NS.tck -force


# correct warpfield and TRANSFORM TO STANDARD-SPACE
warpcorrect ./../ix_warpfield_SS.nii ix_warpfield_SS_corrected.mif -force
tcktransform 10k_NS.tck ix_warpfield_SS_corrected.mif 10k_SS.tck -force


#[ -e file ] && rm densMap_10k_SS.nii
tckmap -dec -template ./../AVGT.nii 10k_SS.tck densMap_10k_SS.nii -force
#tckmap -dec -vox 0.05 -template ./../AVGT.nii 10k_SS.tck densMap_10k_SS_v2.nii -force

#mrview ./../AVGT.nii -mode 2 -overlay.load densitymap_SS.nii -overlay.opacity .7 -noannotations -overlay.threshold_min 1 -overlay.intensity 0,5 &


# for display-purpose
mrtransform fa_NS.mif fa_SS.nii -warp ./../x_warpfield_NS.nii -template ./../AVGT.nii -interp linear  -force
#================================================================
cd $dirThis # go back to entry-folder