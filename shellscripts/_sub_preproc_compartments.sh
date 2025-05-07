#!/bin/bash
# preprocessing-subfunction
# vers. 20.09.23 
#---------------------------------------------

echo "RUNNING SCRIPT:" $(basename "$0")



# #########################################################################
#       SOME variables
# #########################################################################
dirBase=$(dirname "$(pwd)")
dirNumeric=$(basename "$(pwd)")
dirAnimal=$(ls -d */|head -n 1)
dirAnimalFP="$(pwd)/$dirAnimal"     ; #echo $dirAnimalFP ; #exit 1
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
# #########################################################################
#       [READ CONFIG-FILE]
# #########################################################################
parentdir="$(dirname $(dirname $0))"
#CFG_FILE=$basepath/config.txt
CFG_FILE=$parentdir/config.txt
CFG_CONTENT=$(cat $CFG_FILE | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g') # # https://askubuntu.com/questions/743493/best-way-to-read-a-config-file-in-bash
eval "$CFG_CONTENT"


#exit 0

# ---------------------------------------------------------------------------------
# c1t2 (gm)
if [ 1 -eq 1 ]; then
	echo "work on GM-compartment"
	for_each * : mrconvert IN/rc_c1t2.nii IN/mrtrix/gm_maskcorruptheader.mif -force
	for_each * : mrtransform IN/mrtrix/gm_maskcorruptheader.mif -replace IN/mrtrix/dwi_den_unr_pre.mif IN/mrtrix/gm_mask.mif -force
	for_each * : mrgrid IN/mrtrix/gm_mask.mif regrid -template IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif -interp nearest IN/mrtrix/gm_mask_up.mif -force
	# threshold at .99
	for_each * : mrthreshold -abs 0.99 IN/mrtrix/gm_mask_up.mif IN/mrtrix/gm_mask_up_thresh.mif -force
	# erode
	for_each * : maskfilter -npass 2 IN/mrtrix/gm_mask_up_thresh.mif erode IN/mrtrix/gm_mask_up_thresh_erode.mif  -force
	for_each * : dwi2response manual IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif IN/mrtrix/gm_mask_up_thresh_erode.mif IN/mrtrix/gm.txt -scratch IN/mrtrix/scratch -force -lmax 0,0,0,0,0
fi

# ---------------------------------------------------------------------------------
# c2t2 (wm)
if [ 1 -eq 1 ]; then
	echo "work on WM-compartment"
	for_each * : mrconvert IN/rc_c2t2.nii IN/mrtrix/wm_maskcorruptheader.mif -force
	for_each * : mrtransform IN/mrtrix/wm_maskcorruptheader.mif -replace IN/mrtrix/dwi_den_unr_pre.mif IN/mrtrix/wm_mask.mif -force
	for_each * : mrgrid IN/mrtrix/wm_mask.mif regrid -template IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif -interp nearest IN/mrtrix/wm_mask_up.mif -force
	# threshold at .99
	for_each * : mrthreshold -abs 0.99 IN/mrtrix/wm_mask_up.mif IN/mrtrix/wm_mask_up_thresh.mif -force
	# erode
	for_each * : maskfilter -npass 2 IN/mrtrix/wm_mask_up_thresh.mif erode IN/mrtrix/wm_mask_up_thresh_erode.mif -force
	for_each * : dwi2response manual IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif IN/mrtrix/wm_mask_up_thresh_erode.mif IN/mrtrix/wm.txt -force # -lmax 0,4,6,8,10
fi

# ---------------------------------------------------------------------------------
# c3t2 (CSF)
if [ 1 -eq 1 ]; then
	echo "work on CSF-compartment"
	for_each * : mrconvert IN/rc_c3t2.nii IN/mrtrix/csf_maskcorruptheader.mif -force
	for_each * : mrtransform IN/mrtrix/csf_maskcorruptheader.mif -replace IN/mrtrix/dwi_den_unr_pre.mif IN/mrtrix/csf_mask.mif -force
	for_each * : mrgrid IN/mrtrix/csf_mask.mif regrid -template IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif -interp nearest IN/mrtrix/csf_mask_up.mif -force
	# threshold at .99
	for_each * : mrthreshold -abs 0.99 IN/mrtrix/csf_mask_up.mif IN/mrtrix/csf_mask_up_thresh.mif -force
	# erode
	# for_each * : maskfilter -npass 2 IN/mrtrix/csf_mask_up_thresh.mif erode IN/mrtrix/csf_mask_up_thresh_erode.mif -force
	for_each * : dwi2response manual IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif IN/mrtrix/csf_mask_up_thresh.mif IN/mrtrix/csf.txt -force -lmax 0,0,0,0,0
fi

# ---------------------------------------------------------------------------------
# checks (convert final compartments to NIFTIs)
if [ 1 -eq 1 ]; then
	for_each * : mrconvert IN/mrtrix/dwi_den_unr_pre.mif IN/mrtrix/dwi_den_unr_pre.nii -force
	for_each * : mrconvert IN/mrtrix/gm_mask_up_thresh_erode.mif IN/mrtrix/gm_mask_up_thresh_erode.nii -force
	for_each * : mrconvert IN/mrtrix/wm_mask_up_thresh_erode.mif IN/mrtrix/wm_mask_up_thresh_erode.nii -force
	for_each * : mrconvert IN/mrtrix/csf_mask_up_thresh.mif IN/mrtrix/csf_mask_up_thresh.nii -force
fi

# -----DWI2FOD----------------------------------------------------------------------------
# % PHILIPP DIFFERNECES BETWEEN (A) vs (B)
# (A) as used in Sarah's data
#-----------------------------
#for_each * : dwi2fod msmt_csd IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif IN/mrtrix/csf.txt IN/mrtrix/csf.mif IN/mrtrix/gm.txt IN/mrtrix/gm.mif IN/mrtrix/wm.txt IN/mrtrix/wm.mif -mask IN/mrtrix/maskantx_up_smooth_thresh_erode.mif -force

# (B) without GM-compartment
#-----------------------------
#for_each * : dwi2fod msmt_csd IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif IN/mrtrix/csf.txt IN/mrtrix/csf.mif IN/mrtrix/wm.txt IN/mrtrix/wm.mif -mask IN/mrtrix/maskantx_up_smooth_thresh_erode.mif  -force

#for_each * : mrconvert -coord 3 0 IN/mrtrix/wm.mif - \| mrcat IN/mrtrix/csf.mif IN/mrtrix/gm.mif - IN/mrtrix/rgb.mif



