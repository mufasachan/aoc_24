count_trailhead_from_position() {
	local position="$1"
	local height=${map[$position]}
	local -n nines_reached_=$2

	if ((height == 9)); then
		nines_reached_["$position"]=1
		return
	fi

	local row col
	IFS=, read -r row col <<<"$position"

	local -a next_positions=("$((row + 1)),$col" "$((row - 1)),$col" "$row,$((col + 1))" "$row,$((col - 1))")

	local height_target
	((height_target = height + 1))

	local i
	for ((i = 0; i < 4; i++)); do
		local next_position="${next_positions[$i]}"
		if [[ "$height_target" == "${map[$next_position]:--1}" ]]; then
			count_trailhead_from_position "$next_position" $2
		fi
	done
}

((n_cols = $(wc -w <"$1")))
declare -A map
declare -a zero_positions
((row = 0))
while read -r line; do
	for ((col = 0; col < n_cols; col++)); do
		if [[ ${line:col:1} == "0" ]]; then
			zero_positions+=("$row,$col")
		fi
		map["$row,$col"]=${line:col:1}
	done
	((row++))
done <"$1"

score=0
for zero_position in "${zero_positions[@]}"; do
	declare -A nines_reached
	count_trailhead_from_position "$zero_position" nines_reached
	((score += ${#nines_reached[@]}))
	unset nines_reached
done
echo $score
