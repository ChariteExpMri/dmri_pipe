#!/bin/bash
# preprocessing
# vers. 09.02.23 
#---------------------------------------------



# #########################################################################
#       SOME DISPLAY INFORMATION
# #########################################################################

dirBase=$(dirname "$(pwd)")
dirNumeric=$(basename "$(pwd)")

dirAnimal=$(ls -d */|head -n 1)
dirAnimalFP="$(pwd)/$dirAnimal"     ; #echo $dirAnimalFP ; #exit 1
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"


#echo "["$dirNumeric"]" $dirAnimal
echo "$(tput setaf 0)$(tput setab 6) "["$dirNumeric"]" $dirAnimal $(tput sgr 0)"

# _________DISPLAY TIME_________
echo "$(tput setaf 0)$(tput setab 3) #start-Preprocessing#   $(tput sgr 0)"
#echo "start-Preprocessing"
date

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
#CFG_CONTENT=$(cat $CFG_FILE | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g') # # https://askubuntu.com/questions/743493/best-way-to-read-a-config-file-in-bash
CFG_CONTENT=$(cat $CFG_FILE | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s*=\s*/=/g' ) # # https://askubuntu.com/questions/743493/best-way-to-read-a-config-file-in-bash

#echo $CFG_CONTENT
eval "$CFG_CONTENT"

	if [[ ( -z $fixBtable ) ]] ; then  fixBtable=0   ; fi  # if not adequately addressed...
    if [[ ( -z $RPE )       ]] ; then        RPE=0   ; fi  # if not adequately addressed...
# ################ DISPLAY DEFAULT PARAMETER


echo "SPECIES  :'$SPECIES'"
echo "DWI_FILES:'$DWI_FILES'"
echo "fixBtable:'$fixBtable'"
echo "RPE      :'$RPE'"
echo "pe_dir   :'$pe_dir' (dwifslpreproc, phase encoding direction)"

# ====================================================
# remove "mrtrix"-folder from false location (i.e. in "a001" instead of "a001/animalname")
# ====================================================
if [ 1 -eq 1 ]; then
	falseFolder="$dirBase/$dirNumeric/mrtrix"
	#echo "falseFolder: $falseFolder "
	if [ -d "$falseFolder" ]; then  # Take action if $falseFolder exists. #
	  echo "remove false folder $falseFolder..."
	  rm -rf $falseFolder
    fi
fi
# ====================================================
# remove "dwibiascorrec"-folder if exist (this folder is created and not deleted during ERRORNOUS dwifslpreproc) .. location (i.e. in "a001")
# ====================================================
find "$dirBase/$dirNumeric/" -type d -name "dwibiascorrec*" -exec rm -rf {} +


#exit 0


# ===========TESTS ====================================
# ====================================================
# exit 0
# ================================================================================

if [ 1 -eq 1 ]; then

	#_________________________________________________________________________________
	# ################################################################################
	# SECTION: CONVERTING DATA, DENOISING, REMOVING GIBBS-RA 
	 echo "$(tput setaf 3) [SECTION: CONVERTING DATA, DENOISING, REMOVING GIBBS-RA]  $(tput sgr 0)"
	# ################################################################################

	#-------make mtrix-folder-----------
    cd $dirAnimal  # gO INTO ANIMAL FOLDER
	#mrcat b1000_AP/ b2000_AP/ b3000_AP/ dwi.mif
	echo "..xreating mrtrix-folder..."
	#for_each * : mkdir IN/mrtrix
	rm -rf mrtrix
    mkdir -p mrtrix
    cd ..


	echo "============[the SPECIES-DEPENDENT]============================="
	if [ "$SPECIES" = "mouse" ]; then
	    echo "mouse-used "
	else
	    echo "rat-used "
	fi


	echo "============[check, are DWI-files defined in config.file]============================="
	#DWI_FILES=$(echo "$DWI_FILES"|sed 's/(//g;s/)//g')
	#DWI_FILES=$(sed "s/ //g" <<< $DWI_FILES)  #remove spaces
	DWI_FILES=$(echo "$DWI_FILES"|sed 's/(//g;s/)//g' | sed -r 's/\r$//')
	

	nFiles=${#DWI_FILES}
	#echo "Length of the string is : $nFiles "
	#echo "DWI_FILES:$DWI_FILES"
	#echo "length:" ${#DWI_FILES[*]}
    #echo "nfiles: $nFiles"
    
  
   
   #exit 0



	if [ "$nFiles" -lt 5 ]; then  #numer of characters
	    for dir in */; do
	        #$dir
	        echo "PATH: $dir"
	        ls
	        DWI_FILES=$(ls $dir | grep -e "^dwi_[^RPE].*.nii$" -e "^dwi_RPE.*.nii$"  )   #find DWI-files but not DWI-RPE-files
	       # DWI_FILES=$(ls $dir | grep -e "^dwi_[^RPE].*.nii$"   ) 
	       # DWI_RPE_FILES=$(ls $dir | grep "^dwi_RPE_.*.nii$")
	        echo "...."
	      
	    done
	        printf "$(tput setaf 5)"["DWI_FILES not defined in config-file"]"  $(tput sgr 0) ...obtain dwi-names from animal-folder \n "
	else
	   read -a DWI_FILES <<< $DWI_FILES
	   printf "$(tput setaf 4)"["DWI_FILES defined in config-file"]"  $(tput sgr 0) ... \n "
	fi

	  echo "DWI-files    : $DWI_FILES"
	  echo "DWI_RPE-files: $DWI_RPE_FILES"
	  echo "concatenate"
	  echo "DWI-files    : $DWI_FILES"










	#exit 0
	# ============[READ DWI-FILES]=============================
	dwfiles=();
	btable=();
	miffiles=();
	btableFixs=();
	miffilesFixs=();
	for ii in ${DWI_FILES[@]};   do 
	    dwfile=$ii;
	    btable=${dwfile/.nii/.txt}
	    miffile=${dwfile/.nii/.mif}
	    btable=${btable/dwi_/grad_}
	    btableFix=${btable/.txt/_fix.txt}
	    miffilesFix=${miffile/.mif/_fix.mif}
	    echo "DATA: "$dwfile  $btable  $btableFix  $miffile  $miffilesFix
	    dwfiles+=("$dwfile")
	    btables+=("$btable")
	    btableFixs+=("$btableFix")
	    miffiles+=("$miffile")
	    miffilesFixs+=("$miffilesFix")
	 done

	
    echo "----ARRAY FORM---------"
    printf 'dwfiles       :'; printf '%s\t' "${dwfiles[@]}" ;printf '%s\n'
    printf 'btables       :'; printf '%s\t' "${btables[@]}" ;printf '%s\n'
    printf 'btableFixs    :'; printf '%s\t' "${btableFixs[@]}" ;printf '%s\n'
    printf 'mif-files     :'; printf '%s\t' "${miffiles[@]}" ;printf '%s\n'
    printf 'mif-filesFixs :'; printf '%s\t' "${miffilesFixs[@]}" ;printf '%s\n'

	num_DWIfiles=${#dwfiles[@]}
	echo "No-DWI-files: $num_DWIfiles"
    #exit 1
	#============ if only one DWI-file exist and the btable name is "grad.txt" ...make a copy with name "dwi.txt"
	#echo "$dirAnimalFP"
		# file="$dirAnimalFP/grad.txt"
		# #echo $file
		# if [[ $num_DWIfiles -eq 1 ]] &&  [[ -f $file ]]; then
		# 	echo "yes:one file & file exist"
		# 	file2="$dirAnimalFP/dwi.txt"
		# 	cp -f $file $file2
		# 	#echo "created: $file2"
		# fi


	#exit 1
	# ============= [check existence of fix_btables ...otherwise create them]
	if [ "$fixBtable" = "0" ]; then
	    echo "use original Btable ($fixBtable) "
    else
		echo "use fixed Btable ($fixBtable) "
		for (( ii=0; ii<${#btableFixs[@]}; ii++ )); do
			  file="$dirAnimalFP/${btableFixs[ii]}"
			  #echo "$file"
			#if [ 1 -eq 0 ]; then # 
			if [ -f $file ]; then       # remove file
		            echo "fixed Btable exist: ${btableFixs[ii]}"
			else
		            echo "fixed Btable does not exist: ${btableFixs[ii]}  ..will be created"
		        $SCRIPTPATH/_sub_makeFixdTables.sh "$dirAnimalFP${btables[ii]}"
			fi
		done

	fi
	# ===========================================
	#exit 1




	echo "============[ original Btables: convert NII to MIF & concatenate MIFS]============================="
	#echo for_each * : mrconvert -grad IN/grad_b100.txt IN/dwi_b100.nii IN/mrtrix/dwi_b100.mif
	#for_each * : mrconvert -grad IN/grad_b100.txt IN/dwi_b100.nii IN/mrtrix/dwi_b100.mif
	#for_each * : mrcat IN/mrtrix/dwi_b100.mif IN/mrtrix/dwi_b900.mif IN/mrtrix/dwi_b1600.mif IN/mrtrix/dwi_b2500.mif IN/mrtrix/dwi.mif

		if [ "$num_DWIfiles" -eq 1 ]; then
		   echo "singleShell"
		   #for_each * : mrconvert -grad IN/grad.txt IN/dwi.nii IN/mrtrix/dwi.mif
		   for_each * : mrconvert -grad IN/${btables[0]} IN/${dwfiles[0]} IN/mrtrix/dwi.mif
         #copy of orig file
         for_each * : mrconvert -grad IN/${btables[0]} IN/${dwfiles[0]} IN/mrtrix/${miffiles[0]}

		
		else
	    #echo "multiShell"
			for (( ii=0; ii<${#btables[@]}; ii++ )); do
			 	for_each * : mrconvert -grad IN/${btables[$ii]} IN/${dwfiles[$ii]} IN/mrtrix/${miffiles[$ii]}
			done
			
			ms="for_each * : mrcat "
			for (( ii=0; ii<${#btables[@]}; ii++ )); do
			    ms="$ms IN/mrtrix/${miffiles[$ii]}"
			done
			ms="$ms IN/mrtrix/dwi.mif"
			eval $ms

			#echo "cmd:$ms"
			#echo "Nbtables: ${#btables[@]}"
			#echo "Nbtables: $num_DWIfiles"
			
	  fi
    #exit 0


       if [ "$fixBtable" = "1" ]; then
       	echo "============[ fixed Btables: convert NII to MIF & concatenate MIFS]============================="
	      echo "..use fixed Btable ($fixBtable)  ... creating 'dwi_fix.mif'"
	 		for (( ii=0; ii<${#btableFixs[@]}; ii++ )); do
			 for_each * : mrconvert -grad IN/${btableFixs[$ii]} IN/${dwfiles[$ii]} IN/mrtrix/${miffilesFixs[$ii]}
			done
			ms="for_each * : mrcat "
			for (( ii=0; ii<${#btableFixs[@]}; ii++ )); do
			    ms="$ms IN/mrtrix/${miffilesFixs[$ii]}"
			done
			ms="$ms IN/mrtrix/dwi_fix.mif"
			eval $ms
			#echo $ms
		fi
	    
	# check tables by exporting back to NII and btables: 
	#mrconvert  IN/mrtrix/dwi.mif IN/mrtrix/dwi_den_unr_vox.nii -export_grad_fsl IN/mrtrix/bvecs.txt IN/mrtrix/bvals.txt -force
	#for_each * : mrinfo  IN/mrtrix/dwi_fix.mif -force -export_grad_fsl IN/mrtrix/bvecs_fix.txt IN/mrtrix/bvals_fix.txt
	# #########################################################################


    #exit 0

	# #########################################################################
	#       MRTRIX-mrcalc etc
	# #########################################################################

	
    # SET NET VALUES TO ZERO
    echo "..set neg value to zero"
    for_each * : mrcalc IN/mrtrix/dwi.mif 0.0 -max IN/mrtrix/dwi.mif -force -quiet #set neg. values to zero
    
	# Get voxel dimensions for scaling later on
	# -----------------------------------------------------------------------------
	# Denoising
	echo "..denoising..."
	for_each * : dwidenoise IN/mrtrix/dwi.mif IN/mrtrix/dwi_den.mif -noise IN/mrtrix/noise.mif
	#for_each * : dwidenoise IN/mrtrix/dwi.mif IN/5_dwi/dwi_den.mif -noise IN/5_dwi/noise.mif

	echo "..mrcalc using dwi.mif ..."
	for_each * : mrcalc IN/mrtrix/dwi.mif IN/mrtrix/dwi_den.mif -subtract IN/mrtrix/residual.mif
	for_each * : mrcalc IN/mrtrix/dwi_den.mif 0.0 -max IN/mrtrix/dwi_den.mif -force -quiet  #set neg. values to zero


	####### INTERNAL STUFF ##########################################
	#echo "dwi_den.mif  set neg-numbers to zero"
	#mrcalc dwi_den.mif 0.0 -max dwi_den.mif -force
	# for_each * : mrcalc dwi.mif 0.0 -max dwi.mif -force
	#mrstats dwi_den.mif
	############################################################
	#you could check if the noise.mif is good, I recommend to do it. If you could see a brain in this file, dude, then you meet a problem.
	#Unringing
	#The “axes” option must be adjusted to your dataset: With this option, you inform the algorithm of the plane in which you acquired your data: –axes 0,1 means you acquired axial slices; -axes 0,2 refers to coronal slices and –axes 1,2 to sagittal slices!
	#but basically, I'd never seen sagittal and coronal

	echo "..removing Gibbs ringing artefacts..."
	for_each * : mrdegibbs IN/mrtrix/dwi_den.mif IN/mrtrix/dwi_den_unr.mif -axes 0,1
	for_each * : mrcalc IN/mrtrix/dwi_den_unr.mif 0.0 -max IN/mrtrix/dwi_den_unr.mif -force -quiet  #set neg. values to zero
	# -----------------------------------------------------------------------------


	#Motion and distortion correction
	#Reason: Main reference(s):
	#EPI-distortioncorrection:Hollandetal.,2010(suggestusingapairofb0sin in phase encoding (PE) and reversed PE correction)
	#B0-field inhomogeneity correction: Andersson et al., 2003; Smith et al., 2004 (FSL’s topup tool is called by MRtrix’s preprocessing tool dwipreproc)
	#Eddy-current and movement distortion correction: Andersson and Sotiropoulos, 2016 (FSL’s eddy tool is called by MRtrix’s preprocessing tool dwipreproc)
	#For EPI distortion correction

	#dwiextract dwi_den_unr.mif - -bzero | mrmath – mean mean_b0_AP.mif –axis 3
	#“-axis 3”denotesthatthemeanimagewillbecalculatedalongthethirdaxis
	#mrconvert b0_PA/ - | mrmath – mean mean_b0_PA.mif –axis 3
	#mrcat mean_b0_AP.mif mean_b0_PA.mif –axis 3 b0_pair.mif
	#if no b0_PA/, don't need to do these steps


	#_________________________________________________________________________________
	# ################################################################################
	# SECTION: dwifslpreproc-part 
	 echo "$(tput setaf 3) [SECTION: dwifslpreproc]  $(tput sgr 0)"
	# ################################################################################


	# ==================================
	# (1) automatic voxelsize readout
	# ==================================
	echo "============[the SPECIES-DEPENDENT]============================="
	if [ "$SPECIES" = "mouse" ]; then
	    #echo "mouse-used "
	    fac=15  # voxelsize inflation factor to inflate the brain (for FSL)
	elif [ "$SPECIES" = "rat" ]; then
	    #echo "rat-used "
	    fac=10  # voxelsize inflation factor to inflate the brain (for FSL)
	fi
	printf "$(tput setaf 4)""  SPECIES: $SPECIES  .. using resize Factor:  $fac ""  $(tput sgr 0) \n "
   
    #exit 1
	

  # -----GET VOXELSIZE FSL-----------
	# cd $(ls -d */|head -n 1)
	# #echo $(pwd)
	# dim1=$(fslinfo rc_t2.nii | grep -m 1 pixdim1 | awk '{print $2}');
	# dim2=$(fslinfo rc_t2.nii | grep -m 1 pixdim2 | awk '{print $2}');
	# dim3=$(fslinfo rc_t2.nii | grep -m 1 pixdim3 | awk '{print $2}');
	# echo '['$dim1','$dim2','$dim3']'
	# cd ..

  # -----GET VOXELSIZE MRtrix via dwi.mif -----------
	#pwd
	echo "..get voxel-size from dwi.mif"
	cd $dirAnimal/mrtrix  # gO INTO ANIMAL FOLDER
	#ls
	dim1=$(mrinfo dwi.mif -spacing | awk '{print $1}'); #echo "vox-dim1: $dim1";
	dim2=$(mrinfo dwi.mif -spacing | awk '{print $2}'); #echo "vox-dim2: $dim2";
	dim3=$(mrinfo dwi.mif -spacing | awk '{print $3}'); #echo "vox-dim3: $dim3";
	echo 'vox-dims: ['$dim1','$dim2','$dim3']'
	cd ../../
	#pwd
	#ls



	# FLOAT-op: https://www.linuxquestions.org/questions/linux-software-2/multiply-floats-in-bash-script-618691/
	dim1fac=$(echo $dim1 $fac | awk '{printf $1*$2}')
	dim2fac=$(echo $dim2 $fac | awk '{printf $1*$2}')
	dim3fac=$(echo $dim3 $fac | awk '{printf $1*$2}')
	echo "INFLATE BRAIN: scale to human length scales for FSL commands and then back to original length scales..."
	echo "  voxel inflation Factor: " $fac
	echo "      original voxelsize:" [$dim1,$dim2,$dim3]
	echo "       resized voxelsize:" [$dim1fac,$dim2fac,$dim3fac]

	# __using BC for float-operations ____
	#dim1fac=$(echo $dim1*$fac | bc)
	#dim2fac=$(echo $dim2*$fac | bc) 
	#dim3fac=$(echo $dim3*$fac | bc)
	#echo '['$dim1fac','$dim2fac','$dim3fac']'


	# ==================================
	# (2) inflate brain
	# ==================================
	#motion and distortion correction, scale to human length scales for FSL commands and then back to original length scales
	echo "..changing voxelSize..."
	                 #for_each * : mrconvert -vox 1,1,4 IN/mrtrix/dwi_den_unr.mif IN/mrtrix/dwi_den_unr_vox.mif
    for_each * : mrconvert -force -vox $dim1fac,$dim2fac,$dim3fac IN/mrtrix/dwi_den_unr.mif IN/mrtrix/dwi_den_unr_vox.mif


fi

#exit 0

if [ 1 -eq 1 ]; then

	# ====================================================
	# (3a) 	RUN [PRE]-DWIPREPROC for FIXED TABLE
	# ====================================================
	if [ "$fixBtable" = "1" ]; then
		echo "..runing dwifslpreproc-part..."
		 # (1) export orig-bvals
		 for_each * : mrconvert  IN/mrtrix/dwi_den_unr_vox.mif IN/mrtrix/dwi_den_unr_vox.nii -export_grad_fsl IN/mrtrix/bvecs.txt IN/mrtrix/bvals.txt -force

		# (2) export fixed-bvals
		for_each * : mrinfo  IN/mrtrix/dwi_fix.mif -force -export_grad_fsl IN/mrtrix/bvecs_fix.txt IN/mrtrix/bvals_fix.txt

		# (3) replace b-values with fixed bvalues
		for_each * : mrconvert IN/mrtrix/dwi_den_unr_vox.nii IN/mrtrix/dwi_den_unr_vox.mif -fslgrad IN/mrtrix/bvecs.txt IN/mrtrix/bvals_fix.txt -force

		# (4) check whether b-table is updated
		# for_each * : mrinfo  IN/mrtrix/dwi_den_unr_vox.mif -force -export_grad_fsl IN/mrtrix/bvecs_UD1.txt IN/mrtrix/bvals_UD1.txt
	fi
	# ====================================================
	# (3b) 	RUN dwifslpreproc
	# ====================================================
    echo "RUN DWI_FSL_PREPROC"
	
    if [ "$RPE" = "0" ]; then
    	echo "..without reversed-phase-encoding (RPE=$RPE)"
		#for_each * : dwifslpreproc IN/mrtrix/dwi_den_unr_vox.mif IN/mrtrix/dwi_den_unr_pre_vox.mif -rpe_none -pe_dir AP -eddy_options " --slm=linear"
		#for_each * : dwifslpreproc IN/mrtrix/dwi_den_unr_vox.mif IN/mrtrix/dwi_den_unr_pre_vox.mif -rpe_none -pe_dir AP -eddy_options " --slm=linear --data_is_shelled --verbose" -scratch IN/mrtrix/scratch 
		 for_each * : dwifslpreproc IN/mrtrix/dwi_den_unr_vox.mif IN/mrtrix/dwi_den_unr_pre_vox.mif -rpe_none -pe_dir $pe_dir -eddy_options " --slm=linear --data_is_shelled --verbose" -scratch IN/mrtrix/scratch 
	else
		echo "..with reversed-phase-encoding (RPE=$RPE)"

        
		#obtain index of all 0-values (B0) from "bvals_temp.txt" --> insert them to obtain a reduced mif-file
		#echo "animal: $dirAnimalFP"
		for_each * : mrinfo  IN/mrtrix/dwi_den_unr_vox.mif -force -export_grad_fsl IN/mrtrix/bvecs_temp.txt IN/mrtrix/bvals_temp.txt -force    #obtain B-values
		fileBval_temp=$dirAnimalFP/mrtrix/bvals_temp.txt
		arrText=($(cat $fileBval_temp))
		#echo ${arrText[@]}
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
		#echo "idx_zeroBval: '$idx_zeroBval'"
		#mrconvert $dirAnimalFP/mrtrix/dwi_den_unr_vox.mif $dirAnimalFP/mrtrix/B0paired.nii -coord 3 $idx_zeroBval  -force
		#mrconvert $dirAnimalFP/mrtrix/dwi_den_unr_vox.mif $dirAnimalFP/mrtrix/B0paired.mif -coord 3 $idx_zeroBval  -force    # create new MIF B0-maps (i.e. use the B0-indices) 
		for_each * :  mrconvert IN/mrtrix/dwi_den_unr_vox.mif IN/mrtrix/B0paired.mif -coord 3 $idx_zeroBval  -force    # create new MIF B0-maps (i.e. use the B0-indices) 
		#mrinfo $dirAnimalFP/mrtrix/B0paired.mif -all


	   # for_each * : dwifslpreproc IN/mrtrix/dwi_den_unr_vox.mif IN/mrtrix/dwi_den_unr_pre_vox.mif -rpe_pair -se_epi IN/mrtrix/B0paired.mif -pe_dir AP -align_seepi -eddy_options " --slm=linear --data_is_shelled --verbose" -scratch IN/mrtrix/scratch 
	     for_each * : dwifslpreproc IN/mrtrix/dwi_den_unr_vox.mif IN/mrtrix/dwi_den_unr_pre_vox.mif -rpe_pair -se_epi IN/mrtrix/B0paired.mif -pe_dir $pe_dir -align_seepi -eddy_options " --slm=linear --data_is_shelled --verbose" -scratch IN/mrtrix/scratch 

 

	fi
    #exit 0

   # ======================== ==================================================================
	#-info -nocleanup -config BValueEpsilon 250.0
	# dummy
	#for_each * : cp IN/mrtrix/dwi_den_unr_vox.mif IN/mrtrix/dwi_den_unr_pre_vox.mif 

  	# ====================================================
	# (3c) 	RUN [POST]-DWIPREPROC for FIXED TABLE
	# ====================================================
     if [ "$fixBtable" = "1" ]; then
		# -------POST-PREPOC-----------------------------------------------------------------
		# (5) export bvecs and bvals after PREPROC
		for_each * : mrconvert  IN/mrtrix/dwi_den_unr_pre_vox.mif IN/mrtrix/dwi_den_unr_pre_vox.nii -export_grad_fsl IN/mrtrix/bvecs_PP.txt IN/mrtrix/bvals_PP.txt -force

		# (6) replace b-values with ORIGINAL bvalues
		for_each * : mrconvert IN/mrtrix/dwi_den_unr_pre_vox.nii IN/mrtrix/dwi_den_unr_pre_vox.mif -fslgrad IN/mrtrix/bvecs_PP.txt IN/mrtrix/bvals.txt -force

		# (7) check whether b-table is updated (i.e the orig bvalues are used)
		for_each * : mrinfo  IN/mrtrix/dwi_den_unr_pre_vox.mif -force -export_grad_fsl IN/mrtrix/bvecs_UD2.txt IN/mrtrix/bvals_UD2.txt

		# (8) clean-up (remove NIFTIs)
		for_each * : rm IN/mrtrix/dwi_den_unr_vox.nii
		for_each * : rm IN/mrtrix/dwi_den_unr_pre_vox.nii
	fi
fi


#exit 1

if [ 1 -eq 1 ]; then

	# ==================================
	# (4) RESTORE ORIGINAL VOXELSIZE
	# ==================================
	echo "..restoring original voxelSize..."
	              #for_each * : mrconvert -vox 0.1,0.1,0.4 IN/mrtrix/dwi_den_unr_pre_vox.mif IN/mrtrix/dwi_den_unr_pre.mif
	for_each * : mrconvert -force -vox $dim1,$dim2,$dim3 IN/mrtrix/dwi_den_unr_pre_vox.mif IN/mrtrix/dwi_den_unr_pre.mif


	# ==================================
	# (5) remove neg values & calc
	# ==================================
	# remove negative values from dwi dataset since this leads to problems in ants N4 bias field correction
	for_each * : mrthreshold -abs 0 IN/mrtrix/dwi_den_unr_pre.mif IN/mrtrix/maskprepos.mif

	echo "..runing mrcalc for dwi_den_unr_pre.mif..."
	for_each * : mrcalc IN/mrtrix/dwi_den_unr_pre.mif IN/mrtrix/maskprepos.mif -multiply IN/mrtrix/dwi_den_unr_pre_pos.mif
fi






if [ 1 -eq 1 ]; then
	# -----------------------------------------------------------------------------
	#_________________________________________________________________________________
	# ################################################################################
	# SECTION: BIAS-FIElD CORRECTION 
	echo "$(tput setaf 3) [SECTION: BIAS-FIElD CORRECTION]  $(tput sgr 0)"
	# ################################################################################

	#if you do the b0 step, then use the following command:
	#dwipreproc dwi_den_unr.mif dwi_den_unr_preproc.mif –pe_dir AP –rpe_pair –se_epi b0_pair.mif –eddy_options “ --slm=linear”
	#Calculate the number of outlier slices
	#cd dwipreproc-tmp-*
	#totalSlices=`mrinfo dwi.mif | grep Dimensions | awk '{print $6 * $8}'`
	#totalOutliers=`awk '{ for(i=1;i<=NF;i++)sum+=$i } END { print sum }' dwi_post_eddy.eddy_outlier_map`
	#echo "If the following number is greater than 10, you may have to discard this subject because of too much motion or corrupted slices"
	#echo "scale=5; ($totalOutliers / $totalSlices * 100)/1" |bc | tee percentageOutliers.txt
	#cd ..
	#Bias field correction
	# Use rc_mt2.nii/rc_t2.nii which are the SPM biasfield-corrected/uncorrected t2 coregistered to dwi, requires preprocessing in ANTx2 toolbox https://github.com/ChariteExpMri/antx2
   # -------[BIAS-FIELD-CORRECTION: using SPM-mt2.nii .. OLDER VERSION]--------------------------------------------------------------------------------------------------
   if [ 0 -eq 1 ]; then
		echo "..mrconvert rc_mt2.nii & transform..."
		for_each * : mrconvert IN/rc_mt2.nii IN/mrtrix/rc_mt2corruptheader.mif
		for_each * : mrtransform IN/mrtrix/rc_mt2corruptheader.mif -replace IN/mrtrix/dwi_den_unr_pre.mif IN/mrtrix/rc_mt2.mif

		echo "..mrconvert rc_t2.nii & transform..."
		for_each * : mrconvert IN/rc_t2.nii IN/mrtrix/rc_t2corruptheader.mif
		for_each * : mrtransform IN/mrtrix/rc_t2corruptheader.mif -replace IN/mrtrix/dwi_den_unr_pre.mif IN/mrtrix/rc_t2.mif

		echo "..mrcalc using rc_t2.mif..."
		for_each * : mrcalc IN/mrtrix/rc_mt2.mif IN/mrtrix/rc_t2.mif -divide IN/mrtrix/biasantx.mif

		# do the bias field correction using the antx t2 biasfield
		echo "..mrcalc using dwi_den_unr_pre_pos.mif..."
		for_each * : mrcalc IN/mrtrix/dwi_den_unr_pre_pos.mif IN/mrtrix/biasantx.mif -multiply IN/mrtrix/dwi_den_unr_pre_pos_unbiasantxcorruptheader.mif

		echo "..mrtransform dwi_den_unr_pre_pos_unbiasantxcorruptheader.mif"
		for_each * : mrtransform IN/mrtrix/dwi_den_unr_pre_pos_unbiasantxcorruptheader.mif -replace IN/mrtrix/dwi_den_unr_pre.mif IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx.mif

		# generate brain mask output from antx2 in mif format and fix header
		echo "..mrconvert rc_ix_AVGTmask.nii & transform..."
		for_each * : mrconvert IN/rc_ix_AVGTmask.nii IN/mrtrix/maskantxcorruptheader.mif
		for_each * : mrtransform IN/mrtrix/maskantxcorruptheader.mif -replace IN/mrtrix/dwi_den_unr_pre.mif IN/mrtrix/maskantx.mif

		# Ants biasfieldcorrection. Use ants.b parameter to compensate differences in brain size from human (standard is -ants.b [100,3]) to mouse
		echo "..running  dwibiascorrect..."
		for_each * : dwibiascorrect ants -ants.b "[10,3]" -mask IN/mrtrix/maskantx.mif IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx.mif IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias.mif -bias IN/mrtrix/bias.mif
   fi
   # -----------[BIAS-FIELD-CORRECTION: ANTs-N4]----------------------------------------------------------------------------------------------
   # new_____run ANTs-N4-algorithm twice_________
   # generate brain mask output from antx2 in mif format and fix header
   echo "..mrconvert rc_mt2.nii & transform..."
	for_each * : mrconvert IN/rc_mt2.nii IN/mrtrix/rc_mt2corruptheader.mif
	for_each * : mrtransform IN/mrtrix/rc_mt2corruptheader.mif -replace IN/mrtrix/dwi_den_unr_pre.mif IN/mrtrix/rc_mt2.mif

	echo "..mrconvert rc_t2.nii & transform..."
	for_each * : mrconvert IN/rc_t2.nii IN/mrtrix/rc_t2corruptheader.mif
	for_each * : mrtransform IN/mrtrix/rc_t2corruptheader.mif -replace IN/mrtrix/dwi_den_unr_pre.mif IN/mrtrix/rc_t2.mif

	echo "..mrcalc using rc_t2.mif..."
	for_each * : mrcalc IN/mrtrix/rc_mt2.mif IN/mrtrix/rc_t2.mif -divide IN/mrtrix/biasantx.mif

	echo "..mrconvert rc_ix_AVGTmask.nii & transform..."
	for_each * : mrconvert IN/rc_ix_AVGTmask.nii IN/mrtrix/maskantxcorruptheader.mif
	for_each * : mrtransform IN/mrtrix/maskantxcorruptheader.mif -replace IN/mrtrix/dwi_den_unr_pre.mif IN/mrtrix/maskantx.mif

  for_each * : dwibiascorrect ants -ants.b "[10,3]" -mask IN/mrtrix/maskantx.mif IN/mrtrix/dwi_den_unr_pre_pos.mif IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_run1.mif -bias IN/mrtrix/bias_r1.mif -force 
  for_each * : dwibiascorrect ants -ants.b "[10,3]" -mask IN/mrtrix/maskantx.mif IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_run1.mif IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias.mif -bias IN/mrtrix/bias.mif -force
  # ---------------------------------------------------------------------------------------------------------

	# Generate overall biasfield
	echo "..mrcalc using bias.mif..."
	for_each * : mrcalc IN/mrtrix/bias.mif IN/mrtrix/biasantx.mif -divide IN/mrtrix/biasoverall.mif
	#you can check bias.mif if you want

	# -----------------------------------------------------------------------------
	#_________________________________________________________________________________
	# ################################################################################
	# SECTION: IMAGE RE-GRIDDING, FILTERING, THRESHOLDING 
	echo "$(tput setaf 3) [REGRIDDING; FILTERING; THRESHOLDING]  $(tput sgr 0)"
	# ################################################################################


	#resize voxel, smooth mask:
	echo "..mrgrid using dwi_den_unr_pre_pos_unbiasantx_unbias.mif..."
	for_each * : mrgrid IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias.mif regrid -vox 0.1 IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up.mif

	echo "..mrgrid using regrid.mif..."
	for_each * : mrgrid IN/mrtrix/maskantx.mif regrid -vox 0.1 -interp nearest IN/mrtrix/maskantx_up.mif

	echo "..mrfilter using maskantx_up.mif..."
	for_each * : mrfilter IN/mrtrix/maskantx_up.mif smooth IN/mrtrix/maskantx_up_smooth.mif

	echo "..mrthreshold using maskantx_up_smooth.mif..."
	for_each * : mrthreshold IN/mrtrix/maskantx_up_smooth.mif IN/mrtrix/maskantx_up_smooth_thresh.mif

	echo "..maskfilter using maskantx_up_smooth_thresh.mif..."
	for_each * : maskfilter -npass 2 IN/mrtrix/maskantx_up_smooth_thresh.mif erode IN/mrtrix/maskantx_up_smooth_thresh_erode.mif

	# -----------------------------------------------------------------------------
	# remove negative values
	echo "..remove negative values..."
	for_each * : mrthreshold -abs 0 IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up.mif IN/mrtrix/maskpreunbiasuppos.mif



	echo "..mrcalc using dwi_den_unr_pre_pos_unbiasantx_unbias_up.mif..."
	for_each * : mrcalc IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up.mif IN/mrtrix/maskpreunbiasuppos.mif -multiply IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif


	#_________________________________________________________________________________
	# ################################################################################
	# SECTION: IMAGE SEGMENTATION & FIBRE ORIENTATION 
	echo "$(tput setaf 3) [SECTION: IMAGE SEGMENTATION & FIBRE ORIENTATION ]  $(tput sgr 0)"
	# ################################################################################

	#Fiber orientation distribution
	echo "..replace Nan & neg. values to zero from dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos..."

	#remove NAN from dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos
	for_each * : mrcalc IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif -finite IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif 0.0 -if IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif -force -quiet # remove NaN
	#remove neg.Values
	for_each * : mrcalc IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif 0.0 -max IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif -force -quiet #set neg. values to zero

	#remove NAN from dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos
	for_each * : mrcalc IN/mrtrix/maskantx_up_smooth_thresh_erode.mif -finite IN/mrtrix/maskantx_up_smooth_thresh_erode.mif 0.0 -if IN/mrtrix/maskantx_up_smooth_thresh_erode.mif -force -quiet # remove NaN
	#remove neg.Values
	for_each * : mrcalc IN/mrtrix/maskantx_up_smooth_thresh_erode.mif 0.0 -max IN/mrtrix/maskantx_up_smooth_thresh_erode.mif -force -quiet #set neg. values to zero


	# 
	#change dataType: mrconvert ...  -datatype spec float32
	echo "..change data-Type of dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif"
	for_each * : mrconvert IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif -datatype float32 -force -quiet #set neg. values to zero
	echo "..change data-Type of maskantx_up_smooth_thresh_erode.mif"
	for_each * : mrconvert IN/mrtrix/maskantx_up_smooth_thresh_erode.mif IN/mrtrix/maskantx_up_smooth_thresh_erode.mif -datatype float32 -force -quiet #set neg. values to zero


fi


# ========================================================================
#      dwi2response & dwi2fod
# ========================================================================
if [ 1 -eq 1 ]; then
    # ========================================================================
	#   with or without external Tissue-Compartments
	# ========================================================================
	echo "..TISSUE COMPARTMENTS: $useTissueCompartments"
	if [[ ( -z $useTissueCompartments ) ]] ; then
	#if [[ ( -z $useTissueCompartments ) ; then # ||  ( $useTissueCompartments -ne "0" ) ||  ( $useTissueCompartments -ne "1" ) ]] ; then
	   useTissueCompartments=0;
	   #echo "gooes here:"  "'"$useTissueCompartments"'"
	fi

	if [ $useTissueCompartments -eq 1 ]; then
	    echo " ..external tissue-compartments used";    
	    /$SCRIPTPATH/_sub_preproc_compartments.sh	 


	else
	    echo " ..no external tissue-compartments used";
        #exit 0
		#rm -r dwi2response*  #remove scratch-file for
		echo " ..dwi2response using dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos..."
		for_each * : dwi2response dhollander IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif IN/mrtrix/wm.txt IN/mrtrix/gm.txt IN/mrtrix/csf.txt -voxels IN/mrtrix/voxels.mif -mask IN/mrtrix/maskantx_up_smooth_thresh_erode.mif -csf 50 -force
		#echo "..dwi2fod using dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos..."
		#for_each * : dwi2fod msmt_csd IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif IN/mrtrix/csf.txt IN/mrtrix/csf.mif IN/mrtrix/wm.txt IN/mrtrix/wm.mif -mask IN/mrtrix/maskantx_up_smooth_thresh_erode.mif -force
	fi
	#echo "useTissueCompartments:" "'"$useTissueCompartments"'"

	# ========================================================================
	#  dwi2fod
	# ========================================================================
	#( set -o posix ; set ) 
	#echo -e "\033[33m  This is yellow  \033[0m"
    echo "..RUNNING DWI2FOD"
	shell_bvalues=$(mrinfo $dirAnimalFP/mrtrix/dwi.mif -shell_bvalues )   #obtain shell-bvalues
	shell_number=$(($(echo -n "$shell_bvalues" | wc -w )-1))  # minus 1 for b0
	echo " ..shell_bvalues in [dwi.mif]: '$shell_bvalues' "
	echo " ..shell_number: $shell_number (without b0)" 
	echo " ..defined number of compartments for dwi2fod: $numberCompartments (config-file)" 

	# check that shell-number is equal/larger than number of tissue compartments for dwifod ...otherwise set  number of tissue compartments to 2
	 if [ $shell_number -le 1 ] &&  [ $numberCompartments -eq 3 ] ; then
	     echo -e "\033[33m    WARNING: shell_number ($shell_number) which is less than defined number of tissue compartments ($numberCompartments) used for dwi2fod !   \033[0m"
	     echo -e "\033[33m    SOLUTION: Number of tissue compartmends is set to 2 (WM+CSF)  \033[0m"
	     echo "singleshell"
	     numberCompartments=2
	 fi
	echo " ..number of compartments for dwi2fod: $numberCompartments" 

	 if [ $numberCompartments -eq 2 ]; then      # use 2 tissue compartments
	     	# (B) without GM-compartment
		#-----------------------------
		for_each * : dwi2fod msmt_csd IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif IN/mrtrix/csf.txt IN/mrtrix/csf.mif IN/mrtrix/wm.txt IN/mrtrix/wm.mif -mask IN/mrtrix/maskantx_up_smooth_thresh_erode.mif -force
		###for_each * : mrconvert -coord 3 0 IN/mrtrix/wm.mif - \| mrcat IN/mrtrix/csf.mif IN/mrtrix/gm.mif - IN/mrtrix/rgb.mif
	 else                                        # use 3 tissue compartments
	   	# (A) as used in Sarah's data
		#-----------------------------
		for_each * : dwi2fod msmt_csd IN/mrtrix/dwi_den_unr_pre_pos_unbiasantx_unbias_up_pos.mif IN/mrtrix/csf.txt IN/mrtrix/csf.mif IN/mrtrix/gm.txt IN/mrtrix/gm.mif IN/mrtrix/wm.txt IN/mrtrix/wm.mif -mask IN/mrtrix/maskantx_up_smooth_thresh_erode.mif -force
	 fi
fi



#_________________________________________________________________________________
# ################################################################################
# SECTION: MISC. & CLOSING STEPS OF Preprocessing 
echo "$(tput setaf 3) [SECTION: MISC. & CLOSING STEPS OF Preprocessing]  $(tput sgr 0)"
# ################################################################################

# Generate brain-masked, upsampled c_t2.mif for illustration purposes, make sure that c_t2 exists and is correct (moving image, not target image when configuring coreg in antx2)
echo "..mrconvert c_t2.nii & transform ..."

# ----check existence of file
# BACKGROUNDIMAGE FOR SNIPSHOT
BG_image1="c_t2.nii";
BG_image2="rc_t2.nii";
if [ -e $BG_image1 ]; then
  BG_image=$BG_image1;
else
  BG_image=$BG_image2;
fi 
#--------------------------



#for_each * : mrconvert IN/c_t2.nii IN/mrtrix/c_t2corruptheader.mif
for_each * : mrconvert IN/$BG_image IN/mrtrix/c_t2corruptheader.mif
for_each * : mrtransform IN/mrtrix/c_t2corruptheader.mif -replace IN/mrtrix/dwi_den_unr_pre.mif IN/mrtrix/c_t2.mif

echo "..mrgrid  c_t2.mif ..."
for_each * : mrgrid IN/mrtrix/c_t2.mif regrid -vox 0.1 IN/mrtrix/c_t2_up.mif

echo "..mrgrid  biasantx.mif ..."
for_each * : mrgrid IN/mrtrix/biasantx.mif regrid -vox 0.1 -interp nearest IN/mrtrix/biasantx_up.mif

echo "..mrcalc using c_t2_up.mif ..."
for_each * : mrcalc IN/mrtrix/c_t2_up.mif IN/mrtrix/biasantx_up.mif -multiply IN/mrtrix/c_t2_up_unbias.mif

echo "..mrcalc using c_t2_up.mif ..."
for_each * : mrcalc IN/mrtrix/c_t2_up.mif IN/mrtrix/maskantx_up_smooth_thresh_erode.mif -multiply IN/mrtrix/c_t2_up_unbias_masked.mif




# #######################[display end of script]##############################################
echo "$(tput setaf 0)$(tput setab 3) #end of Preprocessing-script# $(tput sgr 0)"


