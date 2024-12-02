file=$1
source ./lib.sh
score=0
while read -r line; do
	read -ra numbers <<< "$line"

	if lineIsFaulty "${numbers[@]}"; then
		((score++))
	fi
done < $file

echo $score

