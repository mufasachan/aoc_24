declare -a positions velocities

while read -r position_ velocity_; do
	positions+=("${position_/p=/}")
	velocities+=("${velocity_/v=/}")
done <"$1"
# I asked AoC for 10,000, 5,000 and 7,5000
# I know that the tree appears in (5,000, 7,500)
declare -i n="${#positions[@]}" n_turns=7500

# test.txt: 11 7
# input.txt: 101 103
declare -i dx=$2 dy=$3 counti
declare -A line_to_count=0
# "slope,y0" -> accumulation score
declare -a slopes=(1 -1)

for ((i_turn = 0; i_turn < n_turns; i_turn++)); do
	line_to_count=()

	for ((i = 0; i < n; i++)); do
		IFS=, read -r x y <<<"${positions[$i]}"
		IFS=, read -r vx vy <<<"${velocities[$i]}"

		((x = (dx + x + vx) % dx))
		((y = (dy + y + vy) % dy))
		positions[i]="$x,$y"

		for slope in "${slopes[@]}"; do
			((y0 = y - x * slope))
			if ((y0 < 0)); then
				((y0 += dy))
			fi
			((line_to_count["$slope,$y0"]++))
		done
	done

	counti=0
	for line in "${!line_to_count[@]}"; do
		if ((line_to_count[$line] > 13)); then
			((counti++))
		fi
	done
	if ((counti > 5)); then
		declare -A map=()
		for y in $(seq 0 $dy); do
			for x in $(seq 0 $dx); do
				map["$y,$x"]='.'
			done
		done

		for ((i = 0; i < n; i++)); do
			IFS=, read -r x y <<<"${positions[$i]}"
			map["$y,$x"]=#
		done

		# +1 !
		echo "turn: $i_turn"
		for y in $(seq 0 $dy); do
			for x in $(seq 0 $dx); do
				echo -n "${map["$y,$x"]}"
			done
			echo
		done
		echo
	fi

done
