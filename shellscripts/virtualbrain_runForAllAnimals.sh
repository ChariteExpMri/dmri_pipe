#!/bin/bash
#prepare data for virual brain, v1
#_____________________________________________________

# Generate "connectome_distances.csv"

echo "$(tput setaf 0)$(tput setab 2) #START $(tput setab 3) [$(basename $0)]   #$(date)  $(tput sgr 0) "
SECONDS=0


#exit 1

basepath=$(pwd)
dirs=*/;


# save files to ./../tvb_files folder
if [ 1 -eq 1 ]; then
CNT=1
for d in $dirs; do   #=== for each of the a001,a002...axx-folder
    cd "$basepath"
    cd "$d";
     #if [ $CNT -eq "1" ]; then 
      #echo "PA: $(pwd) "
      echo "$(tput setaf 6)  ($CNT): "$d"  ..calculating weights..    $(tput sgr 0)"
      for_each * : tck2connectome IN/mrtrix/100m.tck IN/mrtrix/atlas.mif IN/mrtrix/connectome_distances.csv -tck_weights_in IN/mrtrix/tck_weights.txt -scale_length -stat_edge mean -zero_diagonal -symmetric -force
    #fi


    for dir in */ ; do

        # dir=$(realpath -s $dir)
        pathx=$(pwd)
        dir=$(echo "$dir" | sed 's:/*$::')   #remove trailing slash

        savedir=$pathx/$dir/mrtrix/TVB_${dir::-1}
        #echo "DIR: $dir"

          #if [ $CNT -eq "1" ]; then 
          if [ "1" -eq "1" ]; then 
                #echo "inside($dir): $CNT"
               if [ 1 -eq 1 ]; then

               #echo "savedir: $savedir"
                        if [ ! -d $savedir ]; then
                            mkdir -p $savedir
                            echo "HURRA"

                        fi
                        echo "$(tput setaf 6)  ($CNT): "$d" [$dir] ..make TVB-files    $(tput sgr 0)"
                            
                       # Get list of region labels from ANO_DTI.txt
                        #----CENTRES-------------------
                        cat ./$dir/ANO_DTI.txt | tr -s '[:space:]' | cut -d " " -f 3 | tail -n +2 >$savedir/temp1_LA.txt
                        labelstats -output centre ./$dir/mrtrix/atlas.mif >$savedir/temp1_CO.txt
                        paste $savedir/temp1_LA.txt $savedir/temp1_CO.txt > $savedir/temp1_merge.txt
                        sed 's/[[:blank:]]\+/\t/g' $savedir/temp1_merge.txt > $savedir/centres.txt
                        rm -f $savedir/temp1_*.txt

                        #-------tract_lengths----------------
                        # change connectome_distances.csv from comma delimited to tab delimited save to savedir
                        cat ./$dir/mrtrix/connectome_distances.csv | tr '[,]' '[\t]' > $savedir/tract_lengths.txt
                        
                        #-------weights----------------
                        cat ./$dir/mrtrix/connectome_di_sy.csv | tr '[,]' '[\t]' > $savedir/weights.txt

                        # zip folder in savedir - didnt work in server, not sure why
                        #echo $savedir
                        tar -zcf $savedir.gz $savedir -C $savedir .
                        printf '    [dT] %dh:%dm:%ds\n' $(($SECONDS/3600)) $(($SECONDS%3600/60)) $(($SECONDS%60))
                fi
        fi
        CNT=$[$CNT+1]
        

    done
done
fi





dt=$(printf '[dT] %dh:%dm:%ds\n' $(($SECONDS/3600)) $(($SECONDS%3600/60)) $(($SECONDS%60)) )
#echo "dT: $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
printf "$(tput setaf 0)$(tput setab 1) #STOP $(tput setab 3) [$(basename $0)]   #$(date)  $(tput setab 4) $dt $(tput sgr 0) \n"
