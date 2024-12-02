file=$1

source ./lib.sh

score=0
while read -r line; do
	read -ra numbers <<<$line

	if lineIsFaulty "${numbers[@]}"; then
		((score++))
	else
		for ((iLevel = 0; iLevel < ${#numbers[@]}; iLevel++)); do
			numbersNew=("${numbers[@]:0:iLevel}" "${numbers[@]:iLevel+1}")

			if lineIsFaulty "${numbersNew[@]}"; then
				((score++))
				break
			fi
		done
	fi

done <$file

echo $score
