#!/bin/bash
# quality assessment/create screenshots
# vers. 9.5.22, mouse, multishell
#---------------------------------------------

# #########################################################################
#       SOME DISPLAY INFORMATION
# #########################################################################
# Display start time
echo "$(tput setaf 0)$(tput setab 3) #start-QA#   $(tput sgr 0)"

# Display the currently running script
_self="${0##*/}"
echo "$(tput setaf 5)  running script: $_self    $(tput sgr 0)"
# #########################################################################


# Generate screenshots for quality assessment
for_each * : mrview IN/mrtrix/c_t2_up_unbias_masked.mif -overlay.load IN/mrtrix/voxels.mif -quiet -mode 2 -plane 1 -voxel 95,55,79 -noannot -capture.prefix IN/mrtrix/capture_voxels -capture.grab -exit

for_each * : mrview IN/mrtrix/c_t2_up_unbias_masked.mif -odf.load_sh IN/mrtrix/wm.mif -mode 2 -plane 1 -voxel 95,55,79 -noannot -capture.prefix IN/mrtrix/capture_fod -capture.grab -exit

#for_each * : mrview IN/mrtrix/c_t2_up_unbias_masked.mif -tractography.load IN/mrtrix/100M.tck -tractography.lighting 1 -tractography.thickness 0.2 -mode 2 -plane 1 -voxel 95,55,79 -noannot -capture.prefix IN/mrtrix/capture_tck -capture.grab -exit
for_each * : mrview IN/mrtrix/c_t2_up_unbias_masked.mif -tractography.load IN/mrtrix/100K.tck -tractography.lighting 1 -tractography.thickness 0.2 -mode 2 -plane 1 -voxel 95,55,79 -noannot -capture.prefix IN/mrtrix/capture_tck -capture.grab -exit

# Display end time
echo "end:"
date


# #######################[display end of script]##############################################
echo "$(tput setaf 0)$(tput setab 3) #end of QA-script# $(tput sgr 0)"
