process_stones() {
	local -n stone_to_count_="$1"
	local -i n_blinks=$2

	if ((n_blinks-- == 0)); then
		local score=0
		for count in "${stone_to_count_[@]}"; do
			((score += count))
		done
		echo "$score"
		return
	fi

	local -A new_stone_to_count
	local length stone right left
	for stone in "${!stone_to_count_[@]}"; do
		count=${stone_to_count_[$stone]}

		if ((stone == 0)); then
			((new_stone_to_count[1] += $count))
			continue
		fi

		((length = ${#stone}))
		if (((length % 2) == 0)); then
			left="${stone:0:length/2}"
			right=$(("10#${stone:length/2}"))
			((new_stone_to_count[$left] += count))
			((new_stone_to_count[$right] += count))
			continue
		fi
		((left = 2024 * stone))
		((new_stone_to_count[$left] += count))
	done

	stone_to_count_=()
	for stone in "${!new_stone_to_count[@]}"; do
		stone_to_count_[$stone]="${new_stone_to_count[$stone]}"
	done

	process_stones "$1" $n_blinks
}

n_blinks=75
read -ra stones <"$1"
declare -A stone_to_count
for stone in "${stones[@]}"; do
	stone_to_count[$stone]=1
done

process_stones stone_to_count $n_blinks
