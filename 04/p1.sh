find_chars() {
	local row=$1
	local col=$2
	local chars_to_search=$3
	local direction=$4

	# Case no chars_to_search: the initial chars are found!
	if [ -z "$chars_to_search" ]; then
		echo 1
		return
	fi

	local position=$((row * size + col))
	local char_to_search=${chars_to_search:0:1}
	local chars_to_be_searched=${chars_to_search:1}

	# Case search in a defined direction
	if [ -n "$direction" ]; then
		read -r row_direction col_direction <<<"$direction"
		local newrow=$((row + row_direction))
		local newcol=$((col + col_direction))
		if ((newrow < 0 || newrow >= size || newcol < 0 || newcol >= size)); then
			return
		fi

		local newposition=$((newrow * size + newcol))

		if [[ "${characters[newposition]}" == "$char_to_search" ]]; then
			find_chars $((newrow)) $((newcol)) "$chars_to_be_searched" "$direction"
		fi
		return
	fi

	# Case search in all direction
	if [[ "${characters[position]}" != "$char_to_search" ]]; then
		return
	fi

	local score=0
	for direction in "${directions[@]}"; do
		local found_in_direction
		found_in_direction=$(find_chars $((row)) $((col)) "$chars_to_be_searched" "$direction")
		((score += found_in_direction))
	done
	echo $((score))
}

file_path=$1

# remove new line, dissociate each characters, space for new line
read -ra characters <<<"$(tr -d "\n" <"$file_path" | grep -o . | tr "\n" " ")"
size=$(wc -l <"$file_path")
length=$((${#characters[@]}))

# left, right, top, bot, left+top, right+top, left+bot, left+bot
declare -a directions=("-1 0" "-1 1" "-1 -1" "0 1" "0 -1" "1 0" "1 1" "1 -1")

score=0
for position in $(seq 0 $((length - 1))); do
	row=$((position / size))
	col=$((position % size))
	score_position=$(find_chars $((row)) $((col)) "XMAS")
	((score += score_position))
done
echo $score
