find_cross_mas() {
	local row=$1
	local col=$2
	local position=$((row * size + col))

	# Not A => not a cross
	if [[ ${characters[position]} != "A" ]]; then
		echo 0
		return
	fi

	# ..T
	# .p.
	# B..
	local char_botA=${characters[$((position + size - 1))]}
	local char_topA=${characters[$((position - size + 1))]}
	# local is_cross_A=$(((char_botA == "M" && char_topA == "S") || (char_botA == "S" && char_topA == "M")))
	# local is_cross_A=[[ ("$char_botA" == "M" && $"char_topA" == "S") || (char_botA == "S" && char_topA == "M") ]]
	local is_cross_A
	[[ ("$char_botA" == "M" && "$char_topA" == "S") || ("$char_botA" == "S" && "$char_topA" == "M") ]] && is_cross_A=1 || is_cross_A=0

	# T..
	# .p.
	# ..B
	local char_botB=${characters[$((position + size + 1))]}
	local char_topB=${characters[$((position - size - 1))]}
	local is_cross_B
	[[ ("$char_botB" == "M" && "$char_topB" == "S") || ("$char_botB" == "S" && "$char_topB" == "M") ]] && is_cross_B=1 || is_cross_B=0

	(((is_cross_A + is_cross_B) == 2)) && echo 1 || echo 0
}

file_path=$1

# remove new line, dissociate each characters, space for new line
read -ra characters <<<"$(tr -d "\n" <"$file_path" | grep -o . | tr "\n" " ")"
size=$(wc -l <"$file_path")

score=0
for ((row = 1; row < size - 1; row++)); do
	for ((col = 1; col < size - 1; col++)); do
		score_position=$(find_cross_mas $((row)) $((col)))
		((score += score_position))
	done
done

echo $score
