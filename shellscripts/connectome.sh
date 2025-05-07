#!/bin/bash
# connectome reconstruction
# Script reconstructs connectome, does filtering, writes connectivity matrix
# requires ANO.nii atlas and ANO.txt containing all structures and label IDs of the atlas
# vers. 9.5.22, mouse, multishell
#---------------------------------------------

# #########################################################################
#       SOME DISPLAY INFORMATION
# #########################################################################
# Display start time
echo "$(tput setaf 0)$(tput setab 3) #start-CONNECTOME#   $(tput sgr 0)"

# Display the currently running script
_self="${0##*/}"
echo "$(tput setaf 5)  running script: $_self    $(tput sgr 0)"
# #########################################################################

# #########################################################################
#       [READ CONFIG-FILE]
# #########################################################################
parentdir="$(dirname $(dirname $0))"
#CFG_FILE=$basepath/config.txt
CFG_FILE=$parentdir/config.txt
CFG_CONTENT=$(cat $CFG_FILE | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g') # # https://askubuntu.com/questions/743493/best-way-to-read-a-config-file-in-bash
eval "$CFG_CONTENT"
echo "SPECIES: $SPECIES"
echo "DWI_FILES:$DWI_FILES"



# tractography
echo "STARTING  TRACTOGRAPHY...THIS WILL TAKE SOME HOURS...."
echo "============[the SPECIES-DEPENDENT]============================="
if [ "$SPECIES" = "mouse" ]; then
    echo "mouse-used "
    for_each * : tckgen IN/mrtrix/wm.mif IN/mrtrix/100m.tck -seed_dynamic IN/mrtrix/wm.mif -select 100M -maxlength 30 -cutoff 0.06
    for_each * : tckgen IN/mrtrix/wm.mif IN/mrtrix/100k.tck -seed_dynamic IN/mrtrix/wm.mif -select 100K -maxlength 30 -cutoff 0.06
elif [ "$SPECIES" = "rat" ]; then
    echo "rat-used "
    for_each * : tckgen IN/mrtrix/wm.mif IN/mrtrix/100m.tck -seed_dynamic IN/mrtrix/wm.mif -select 100M -maxlength 50 -cutoff 0.06
    for_each * : tckgen IN/mrtrix/wm.mif IN/mrtrix/100k.tck -seed_dynamic IN/mrtrix/wm.mif -select 100K -maxlength 50 -cutoff 0.06
fi


# if [ 1 -eq 1 ];then 
#    echo "calc tck-files"
#    for_each * : tckgen IN/mrtrix/wm.mif IN/mrtrix/100m.tck -seed_dynamic IN/mrtrix/wm.mif -select 100M -maxlength 30 -cutoff 0.06
#    for_each * : tckgen IN/mrtrix/wm.mif IN/mrtrix/100k.tck -seed_dynamic IN/mrtrix/wm.mif -select 100K -maxlength 30 -cutoff 0.06
#    # cutoff optimisation, define CCROI (corpus callosum)
#    #for_each * : tckgen IN/mrtrix/wm.mif IN/mrtrix/5K_cutoff_XX.tck -seed_image IN/mrtrix/CCROI.mif -select 5K -maxlength 30 -cutoff XX
#    # maxlength optimisation, define CCROI (corpus callosum)
#    #for_each * : tckgen IN/mrtrix/wm.mif IN/mrtrix/5K_maxlength_XX.tck -seed_image IN/mrtrix/CCROI.mif -select 5K -maxlength XX -cutoff OPTIMIZEDVALUE
#    # debugging with 10000 seeds
#    #for_each * : tckgen IN/mrtrix/wm.mif IN/mrtrix/10M.tck -seed_dynamic IN/mrtrix/wm.mif -select 10000 -maxlength 250 -cutoff 0.06
# fi

# sift_2
echo "sift-2: CREATE  tck_coeffs.txt-FILE"
for_each * : tcksift2 IN/mrtrix/100m.tck IN/mrtrix/wm.mif IN/mrtrix/tck_weights.txt -out_mu IN/mrtrix/SIFT2_mu.txt -out_coeffs IN/mrtrix/tck_coeffs.txt

# upscale atlas and convert to mif with ascending label ids, probably not needed if original atlas has no missing values in between, check later
#for_each * : mrresize IN/rc_ix_ANO.nii -vox 0.1 -interp  IN/mrtrix/ANO_up.mif
echo "CREATE atlas_lut/atlas.mif"
for_each * : cp IN/ANO_DTI.txt IN/mrtrix/atlas_lut.txt
for_each * : labelconvert IN/ANO_DTI.nii IN/ANO_DTI.txt IN/mrtrix/atlas_lut.txt IN/mrtrix/atlas.mif

# ============ISSUE TO BE RESOLVED !!!!===================
# in rat-shellscript there the following two lines are used
#   for_each * : mrgrid IN/ANO_DTI.nii regrid -vox 0.1 -interp nearest IN/mrtrix/ANO_DTI_up.mif 
#   for_each * : labelconvert IN/mrtrix/ANO_DTI_up.mif IN/ANO_DTI.txt IN/atlas_lut.txt IN/mrtrix/atlas.mif
# whereas for mouse this lines are used
#   for_each * : cp IN/ANO_DTI.txt IN/mrtrix/atlas_lut.txt
#   for_each * : labelconvert IN/ANO_DTI.nii IN/ANO_DTI.txt IN/mrtrix/atlas_lut.txt IN/mrtrix/atlas.mif
#    ----- MUST BE SOLVED !!!!! 
# ========================================================


# inpect AAL brain pacellations
#mrview ../t1.nii.gz -plane 2 \ -overlay.load parc_aal.mif -overlay.opacity 0.2 -overlay.colourmap 3 -overlay.interpolation 0 &
#head -n 50 aal.txt

# connectome edge: sum of SIFT1 tractogram
echo "CREATE assignments_di_sy.txt"
for_each * : tck2connectome IN/mrtrix/100m.tck IN/mrtrix/atlas.mif IN/mrtrix/connectome_di_sy.csv -tck_weights_in IN/mrtrix/tck_weights.txt -out_assignments IN/mrtrix/assignments_di_sy.txt -zero_diagonal -symmetric

# generate exemplar streamlines for edges visualisation
for_each * : connectome2tck IN/mrtrix/100m.tck IN/mrtrix/assignments_di_sy.txt IN/mrtrix/exemplars.tck -tck_weights_in IN/mrtrix/tck_weights.txt -exemplars IN/mrtrix/atlas.mif -files single

# generate a smooth surface representation of each parcellation
for_each * : label2mesh IN/mrtrix/atlas.mif IN/mrtrix/mesh.obj;
for_each * : meshfilter IN/mrtrix/mesh.obj smooth IN/mrtrix/smoothed_atlas.obj


# #######################[display end of script]##############################################
echo "$(tput setaf 0)$(tput setab 3) #end of CONNECTOME-script# $(tput sgr 0)"

