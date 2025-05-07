#!/bin/bash

#printf "\033[197m\033[42m *** create fixed gradTables *** \033[0m \n";
printf "$(tput setaf 5)""creating fixed gradTables""  $(tput sgr 0) ...obtain dwi-names from animal-folder \n "


echo $1



file=$1;# "grad_b100.txt"
file2=${file/.txt/_fix.txt}
#btable=${dwfile/.nii/.txt}

echo $file



declare -a d1=(); declare -a d2=();declare -a d3=(); declare -a d4=() ; declare -a d44=()
count=0;
total=0; 


no=1;
while read c1 c2 c3 c4; do
   # echo "$c1 $c2 $c3 $c4"
   d1+=("$c1"); 
   d2+=("$c2");
   d3+=("$c3");
   d4+=("$c4");
   d44+=("$c4");
    #echo "$i"
       if [ "$c4" != "0" ]; 
       then
         #  echo "larger: $c4"
           total=$(echo $total+$c4 | bc )
     ((count++))
      fi
      no=$((no+1))
      #$((num1 + 2 + 3))
      #echo $no
      #echo ${d44[-1]}
      #echo $(({d4[-1]}*100))
      #d44[-1]=$(echo ${d44[-1]}+100 | bc )
      #echo ${d44[-1]}

      #printf "round: %.0f" $(echo "${d44[-1]}" | bc)
      d44[-1]=$(printf "%.0f\n" $( echo "scale=2; ${d44[-1]}/100" | bc))  #divide by 100
      d44[-1]=$(printf "%.0f\n" $( echo "scale=2; ${d44[-1]}*100" | bc))  #multiply by 100 again
      #echo "E:${d44[-1]}"
done < "$file"
# echo "------"
# echo "${d1[@]}"
# echo "${d2[@]}"
# echo "${d3[@]}"
# echo "d4    : ${d4[@]}"
# echo "count : ${count[@]}"
# echo "total : $total "




#file2="file.txt"
if [ -f "$file2" ]; then
    rm $file2
fi
touch $file2
for (( i=0; i<${#d4[@]}; i++ )); do
   echo "${d1[$i]} ${d2[$i]} ${d3[$i]} ${d44[$i]}"   >> $file2 
done


#echo "_______________new table_____________" ;
#cat $file2







