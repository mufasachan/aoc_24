txtfile=$1

column1=($(cut --fields=1 --delimiter=" " $txtfile | sort))
column2=($(cut --fields=4 --delimiter=" " $txtfile | sort))
nRows=$((${#column1[@]}-1))

score=0
for i in $(seq 0 $nRows);
do
	difference_i=$((column1[i] - column2[i]))
	score_i=${difference_i#-}
	score=$((score+score_i))
	
	# echo "${column1[$i]} ${column2[$i]}"
	# echo $score_i
done

echo $score
