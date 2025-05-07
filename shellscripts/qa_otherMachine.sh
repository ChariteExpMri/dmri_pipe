#!/bin/bash


# ==============================================================================================================
#         HELP QA
# ==============================================================================================================
   
[ "$1" = "-h" -o "$1" = "--help" ] && echo "
Generate QA-snapshot-images for quality assessment using ANOTHER MACHINE WITH GRAPHIC SUPPORT
REASON: HPC-cluster has NO GRAPHIC SUPPORT
-----------------------------

 ASSUMPTION:
 - It is assumed that all data are processed on the HPC-cluster.
 - for QA this scripts runs over ALL animals and creates screenshots
 - if scrennshots already exist for an animal no new screenshots will be created for the same animal, but see '_HOW TO RUN__'

__MANDATORY DATA-STRUCTURE__
 The folder 'data' contains numeric folders ('a001','a002'...). Each of this folder contains 
   one animalfolder with the DTI-data
 screenshots are only obtained if the DTI-pipeline for an animal is finished, i.e if:
    (a)the sub-folder 'mrtrix' exists, and
    (b)the file 'smoothed_atlas.obj' (the last file created by the DTI-pipline) exists in the mrtrix-folder, and


 HPC_STUDYFOLDER 
	├───shellscripts
	└───data
		├───a001
		│   └───20201022MG_LAERMRT_MGR00031
		│       
		└───a002
			└───20201022MG_LAERMRT_MGR00032

_HOW TO RUN__
 (1) go to the 'data'-folder:
     example: cd /mnt/sc-project-agtiermrt/Daten-2/Imaging/Paul_DTI/groeschel_test4Ernst/data
      running the shellscript assumes that the folder 'shellscripts' (containing the QA-script) is located at the same 
      hierarchical level as the 'data'-folder
 (2) run script  via..
     ----------------------------
     (2a) do not overwrite-mode: 
     ----------------------------
     ./../shellscripts/qa_otherMachine.sh
     
     ---1st INPUT-ARG: force to overwrite [0/1] -----------------
     (2b) overwrite-mode (force to overwrite QA-snapshot-images): 
     ./../shellscripts/qa_otherMachine.sh 1
    ---2nd INPUT-ARG: run only on specific animal -----------------
     (2c) example make screenshots only for animal-1 'a001'
     ./../shellscripts/qa_otherMachine.sh 1 a001

 _HELP_
 to get help execute:
 ./../shellscripts/qa_otherMachine.sh -h

 ==============================================================================================================
 version:   22.12.23   --> fixed help (qa_otherMachine instead of mouse_qa_otherMachine)
            33.11.23   --> 1st screenshot: if 'voxles.mif' does not exist, only BG_image is saved as screenshot
# ==============================================================================================================



" && exit

# ==============================================================================================================
#         start QA
# ==============================================================================================================
printf "\033[197m\033[42m *** QUALITY-ASSESSMENT *** \033[0m \n";
printf "\033[0;35m  =========================================================== \033[0m\n";
printf "\033[0;35m  ...creating screenShots(*.png)    \033[0m\n";
printf "\033[0;35m  PATH: $(pwd)                \033[0m\n";
printf "\033[0;35m  DATE: $(date)               \033[0m\n";
printf "\033[0;35m  FILE: $(basename -- "$0")   \033[0m\n";
printf "\033[0;35m  =========================================================== \033[0m\n";


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


doOverwrite=0;
#if [ "$1" = "1" -o "$1" = "0" ]; then
if [ "$1" = "1"  ]; then
   doOverwrite=$1;
   printf "\033[91m *** FORCE TO OVERWRITE & RECREATE IMAGES ***  \033[0m\n";
fi


#doOverwrite=0;
# if [ $doOverwrite -eq 1 ]; then
# 	echo "mode: QA-overwrite";
# 	lastFileCreated=dummyFile123;
# elif [ $doOverwrite -eq 0 ]; then
#     echo "mode: QA-skipped if exist";
#     lastFileCreated=smoothed_atlas.obj;
# else
# 	lastFileCreated=smoothed_atlas.obj;
# fi


# ==============================================================================
# ---2nd input argument : SPECIFIC ANIMAL-ID (example: 'a001' or 'a033')---------
# ==============================================================================
dirs=*/;
#echo $dirs


if !([ -z $2 ]);then
	WORD=$2"/"
	#WORD="a041/"
	dirs2="";
	for d in $dirs ; do 
		if [[ "$WORD" =~ ^($d)$ ]]; then
			#echo "$WORD is in the list"
			dirs2=$d;
		fi
	done
    if [ -z $dirs2 ];then
          echo "ERROR...animal-folder not found use animal-ID (example: 'a001' or 'a033') ..terminated   "
          exit;
	else
          dirs=$dirs2;
	fi
fi
echo $dirs

#exit

# ==============================================================================


 

COUNTER=1 ; #counter of succesfull animals running through the pipeline
#for d in */ ; do   #=== for each of the a001,a002...axx-folder
for d in $dirs; do   #=== for each of the a001,a002...axx-folder
    #echo " $COUNTER) ___ case: $d   ____" ;
	cd "$d";
	#ls

	
	for j in */ ; do #=== for each of the animal-folder within a001,a002...axxx-folders
		cd "$j";
		#echo "...subdir";
		#echo "$j" 
		#subpath=$(pwd);
		

		# ---------go inside MRTRIX-folder ------------
		pathMRTRIX=$(pwd)/mrtrix;
		lastFileCreated=smoothed_atlas.obj;
	    #echo $pathMRTRIX
		if [ -d "$pathMRTRIX" ]; then  #=== if "mtrix"-folder exist!
			cd $pathMRTRIX;
			#echo "...got to mrtrix folder: ${pathMRTRIX}..."
			#ls | grep \.png$

             #echo $lastFileCreated

			
			if [[ -f $lastFileCreated ]]; then  #=== if last file was created (i.e. processing finished)
			 # IF HERE THAN DTI-pipeline HAS BEEN FINISHED, because "mtrtrix-folder" is there and last file "smoothed_atlas.obj" exists
			    numfolder=$(echo $d | sed -e 's/[/]//g'); #remove forward slash
				animalfolder=$(echo $j | sed -e 's/[/]//g');
				#TRIMMED=$(echo $VALUE | sed 's:/*$::')
				
				#echo -e "Default \e[34mBlue"
				echo -e "\e[34m $COUNTER) \e[33m [$numfolder] \e[39m   ---> animal: \e[92m '$animalfolder' \e[39m ___________  " ;
			    #echo "animal: $j";
				
				COUNTER=$[$COUNTER +1];


			    echo "=====CHECKS-start ==============="
				echo $(pwd)
				echo "=====CHECKS-end ==============="


                # BACKGROUNDIMAGE FOR SNIPSHOT
                BG_image1="c_t2_up_unbias_masked.mif";
                BG_image2="wm.mif";
                if [ -e $BG_image1 ]; then
                    BG_image=$BG_image1;
                else
                    BG_image=$BG_image2;
                fi
                #echo $BG_image
      
	             #exit
                #===============================================================
				#====== IMAGE-1 ================================================
				#===============================================================
				image=capture_voxels0000.png

                if [ "$doOverwrite" = "1" ]; then    # DELETE FILE TO FORCE TO OVERWRITE IF "doOverwrite" is 1
				[ -e $image ] && rm $image
			    fi
                #--------
				if [[ ! -f $image ]]; then # if file does not exist
				   
			           echo "   ...file '$image' does not exist...creating file..";

							# "============[the SPECIES-DEPENDENT]============================="
							if [ "$SPECIES" = "mouse" ]; then
								   if test -f "voxels.mif"; then
							    	   mrview $BG_image -overlay.load voxels.mif  -quiet -mode 2 -plane 1 -voxel 95,55,79 -noannot -overlay.load voxels.mif -capture.prefix capture_voxels -capture.grab -exit
							    	else
                                       mrview $BG_image -quiet -mode 2 -plane 1 -voxel 95,55,79 -noannot -capture.prefix capture_voxels -capture.grab -exit
							    	fi
							elif [ "$SPECIES" = "rat" ]; then
								if test -f "voxels.mif"; then
									mrview $BG_image -overlay.load voxels.mif  -quiet -mode 2 -plane 1 -voxel 150,80,150 -noannot -overlay.load voxels.mif -capture.prefix capture_voxels -capture.grab -exit
								else
                                    mrview $BG_image -quiet -mode 2 -plane 1 -voxel 150,80,150 -noannot -capture.prefix capture_voxels -capture.grab -exit
							    fi 
							fi
				
				else
					echo "   ...file '$image' already exists..";
				fi

			
                #===============================================================
				#====== IMAGE-2 ================================================
				#===============================================================
				image=capture_fod0000.png

                if [ "$doOverwrite" = "1" ]; then    # DELETE FILE TO FORCE TO OVERWRITE IF "doOverwrite" is 1
				[ -e $image ] && rm $image
			    fi
                #--------

				if [[ ! -f $image ]]; then # if file does not exist
		           echo "   ...file '$image' does not exist...creating file..";
	               

	                   #============[the SPECIES-DEPENDENT]============================="
						if [ "$SPECIES" = "mouse" ]; then
						   mrview $BG_image -odf.load_sh wm.mif -mode 2 -plane 1 -voxel 95,55,79 -noannot -capture.prefix capture_fod -capture.grab -exit
						elif [ "$SPECIES" = "rat" ]; then
                           mrview $BG_image -odf.load_sh wm.mif -mode 2 -plane 1 -voxel 150,80,150 -noannot -capture.prefix capture_fod -capture.grab -exit
						fi
				else
					echo "   ...file '$image' already exists..";
				fi
                #===============================================================
				#====== IMAGE-3 ================================================
				#===============================================================
				image=capture_tck0000.png

                if [ "$doOverwrite" = "1" ]; then    # DELETE FILE TO FORCE TO OVERWRITE IF "doOverwrite" is 1
				[ -e $image ] && rm $image
			    fi
                #--------
				if [[ ! -f $image ]]; then # if file does not exist
		           echo "   ...file '$image' does not exist...creating file..";
						#============[the SPECIES-DEPENDENT]============================="
						if [ "$SPECIES" = "mouse" ]; then
							mrview $BG_image -tractography.load 100k.tck -tractography.lighting 1 -tractography.thickness 0.2 -mode 2 -plane 1 -voxel 95,55,79 -noannot -capture.prefix capture_tck -capture.grab -exit
						elif [ "$SPECIES" = "rat" ]; then
							mrview $BG_image -tractography.load 100k.tck -tractography.lighting 1 -tractography.thickness 0.2 -mode 2 -plane 1 -voxel 150,80,150 -noannot -capture.prefix capture_tck -capture.grab -exit
						fi

				else
					echo "   ...file '$image' already exists..";
				fi				
				#======================================================
				
			fi #=== if last file was created (i.e. processing finished)
			cd ..
         fi #=== if "mtrix"-folder exist!

		 cd ..
	done #=== for each of the animal-folder within a001,a002...axxx-folders
	cd ..
done #=== for each of the a001,a002...axx-folder

# __add timestamp
if [ 1 -eq 1 ]; then
	echo "QA-images created. Done! (`date`)"
fi

#__older___
#for_each * : mrview IN/mrtrix/c_t2_up_unbias_masked.mif -overlay.load IN/mrtrix/voxels.mif  -quiet -mode 2 -plane 1 -voxel 150,80,150 -noannot -overlay.load IN/mrtrix/voxels.mif -capture.prefix IN/mrtrix/capture_voxels -capture.grab -exit

#for_each * : mrview IN/mrtrix/c_t2_up_unbias_masked.mif -odf.load_sh IN/mrtrix/wm.mif -mode 2 -plane 1 -voxel 150,80,150 -noannot -capture.prefix IN/mrtrix/capture_fod -capture.grab -exit

#for_each * : mrview IN/mrtrix/c_t2_up_unbias_masked.mif -tractography.load IN/mrtrix/100k.tck -tractography.lighting 1 -tractography.thickness 0.2 -mode 2 -plane 1 -voxel 150,80,150 -noannot -capture.prefix IN/mrtrix/capture_tck -capture.grab -exit
