#!/bin/bash
# tensor metrics, run preprocessing script first!
# vers. 7.5.24
#---------------------------------------------

# #########################################################################
#       SOME DISPLAY INFORMATION
# #########################################################################
# Display start time
echo "$(tput setaf 0)$(tput setab 3) #start-TENSOR-METRICS#   $(tput sgr 0)"

# Display the currently running script
_self="${0##*/}"
echo "$(tput setaf 5)  running script: $_self    $(tput sgr 0)"
# #########################################################################


dirAnimal=$(ls -d */|head -n 1)
dirAnimalFP="$(pwd)/$dirAnimal"     ; #echo $dirAnimalFP ; #exit 1
echo $dirAnimalFP




# Generate diffusion tensor and kurtosis tensor after removal of negative values
echo "CREATE adc/ad/fa/rd-IMAGES"
for_each * : mrthreshold -abs 0 IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias.mif IN/mrtrix/maskpreunbiaspos.mif -force
for_each * : mrcalc IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias.mif IN/mrtrix/maskpreunbiaspos.mif -multiply IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_pos.mif -force

for_each * : dwi2tensor -mask IN/mrtrix/maskantx.mif IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_pos.mif IN/mrtrix/dt.mif -force

# Calculate diffusion tensor metrics
for_each * : tensor2metric -mask IN/mrtrix/maskantx.mif -adc IN/mrtrix/adc.mif -fa IN/mrtrix/fa.mif -ad IN/mrtrix/ad.mif -rd IN/mrtrix/rd.mif IN/mrtrix/dt.mif -force



FILE=$dirAnimalFP/t2.nii
echo "CONVERT adc/ad/fa/rd to NIFTI"
if test -f "$FILE"; then
    echo "file 't2.nii' exists --> register DWImaps & write NIFTIs"
    
    for_each * : mrregister IN/mrtrix/rc_t2.mif IN/t2.nii -type rigid -transformed IN/mrtrix/rc_t2_NS.nii -rigid_niter 10000 -rigid IN/mrtrix/trafo_NS.txt -force

    for_each * : mrtransform -linear IN/mrtrix/trafo_NS.txt IN/mrtrix/rc_t2.mif  IN/mrtrix/rc_t2_NS.mif -template IN/t2.nii -interp linear  -force
    for_each * : mrtransform -linear IN/mrtrix/trafo_NS.txt IN/mrtrix/adc.mif  IN/mrtrix/adc_NS.mif     -template IN/t2.nii -interp linear  -force
    for_each * : mrtransform -linear IN/mrtrix/trafo_NS.txt IN/mrtrix/fa.mif   IN/mrtrix/fa_NS.mif      -template IN/t2.nii -interp linear  -force
    for_each * : mrtransform -linear IN/mrtrix/trafo_NS.txt IN/mrtrix/ad.mif   IN/mrtrix/ad_NS.mif      -template IN/t2.nii -interp linear  -force
    for_each * : mrtransform -linear IN/mrtrix/trafo_NS.txt IN/mrtrix/rd.mif   IN/mrtrix/rd_NS.mif      -template IN/t2.nii -interp linear  -force
 
    for_each * : mrconvert IN/mrtrix/adc_NS.mif IN/adc.nii -force
    for_each * : mrconvert IN/mrtrix/fa_NS.mif  IN/fa.nii  -force
    for_each * : mrconvert IN/mrtrix/ad_NS.mif  IN/ad.nii  -force
    for_each * : mrconvert IN/mrtrix/rd_NS.mif  IN/rd.nii  -force
else
    echo "file 't2.nii' does not exists --> write DWImaps as NIFTIs"
    for_each * : mrconvert IN/mrtrix/adc.mif IN/adc.nii -force
    for_each * : mrconvert IN/mrtrix/fa.mif  IN/fa.nii  -force
    for_each * : mrconvert IN/mrtrix/ad.mif  IN/ad.nii  -force
    for_each * : mrconvert IN/mrtrix/rd.mif  IN/rd.nii  -force
fi
exit 0





# #######################[display end of script]##############################################
echo "$(tput setaf 0)$(tput setab 3) #end of TENSOR-METRICS-script# $(tput sgr 0)"


