declare -a positions velocities

while read -r position_ velocity_; do
	positions+=("${position_/p=/}")
	velocities+=("${velocity_/v=/}")
done <"$1"
declare -i n="${#positions[@]}" n_turns=100

# test.txt: 11 7
# input.txt: 101 103
declare -i dx=$2 dy=$3

for ((i_turn = 0; i_turn < n_turns; i_turn++)); do
	for ((i = 0; i < n; i++)); do
		IFS=, read -r x y <<<"${positions[$i]}"
		IFS=, read -r vx vy <<<"${velocities[$i]}"

		((x = (dx + x + vx) % dx))
		((y = (dy + y + vy) % dy))
		positions[i]="$x,$y"
	done
done

declare -i tl=0 tr=0 bl=0 br=0
for ((i = 0; i < n; i++)); do
	IFS=, read -r x y <<<"${positions[$i]}"
	echo "${positions[i]}: x:$x, y:$y"
	((x < dx / 2 && y < dy / 2)) && ((tl++))
	((x > dx / 2 && y < dy / 2)) && ((tr++))
	((x < dx / 2 && y > dy / 2)) && ((bl++))
	((x > dx / 2 && y > dy / 2)) && ((br++))
done

declare -i score=$((tl * tr * bl * br))
echo "$score"
