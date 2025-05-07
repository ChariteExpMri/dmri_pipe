#!/bin/bash
#prepare data for virual brain, v1
#_____________________________________________________

echo "$(tput setaf 0)$(tput setab 2) #START $(tput setab 3) [$(basename $0)]   #$(date)  $(tput sgr 0) "
SECONDS=0


# Generate "connectome_distances.csv"
for_each * : tck2connectome IN/mrtrix/100m.tck IN/mrtrix/atlas.mif IN/mrtrix/connectome_distances.csv -tck_weights_in IN/mrtrix/tck_weights.txt -scale_length -stat_edge mean -zero_diagonal -symmetric -force

# save files to ./../tvb_files folder
for dir in */; do
  
    # dir=$(realpath -s $dir)
    pathx=$(pwd)
    savedir=$pathx/$dir/mrtrix/TVB_${dir::-1}
    echo $savedir


 #exit 1
    if [ ! -d $savedir ]; then
        mkdir -p $savedir
    fi

    
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


done

dt=$(printf '[dT] %dh:%dm:%ds\n' $(($SECONDS/3600)) $(($SECONDS%3600/60)) $(($SECONDS%60)) )
#echo "dT: $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
printf "$(tput setaf 0)$(tput setab 1) #STOP $(tput setab 3) [$(basename $0)]   #$(date)  $(tput setab 4) $dt $(tput sgr 0) \n"