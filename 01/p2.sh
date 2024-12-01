txtfile=$1

column1=($(cut --fields=1 --delimiter=" " $txtfile | sort))
column2=($(cut --fields=4 --delimiter=" " $txtfile | sort))
nRows=$((${#column1[@]}-1))

declare -A numberToCount
for i in $(seq 0 $nRows);
do
	numberRight="${column2[$i]}"
	numberToCount[$numberRight]="$((${numberToCount[$numberRight]:-0} + 1))"
done

score=0
for i in $(seq 0 $nRows);
do
	numberLeft=${column1[$i]}
	count=${numberToCount[$numberLeft]:-0}
	score_i=$(($count * $numberLeft))

	score=$((score + score_i))
done

echo $score
