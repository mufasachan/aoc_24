file_path=$1

mapfile -t map <"$file_path"
n_rows=${#map[@]}
n_cols=${#map[0]}

declare -A obstacle_positions=()

declare -r BOT_TO_TOP="-1 0"
declare -r LEFT_TO_RIGHT="0 1"
declare -r TOP_TO_BOT="1 0"
declare -r RIGHT_TO_LEFT="0 -1"
declare -a directions=("$BOT_TO_TOP" "$LEFT_TO_RIGHT" "$TOP_TO_BOT" "$RIGHT_TO_LEFT")

for ((i_row = 0; i_row < n_rows; i_row++)); do
	row="${map[i_row]}"
	for ((i_col = 0; i_col < n_cols; i_col++)); do
		element=${row:i_col:1}
		[[ "$element" == "#" ]] && obstacle_positions["$i_row $i_col"]=1
		if [[ "$element" == "^" ]]; then
			row_guard=$i_row
			col_guard=$i_col
			row_direction=-1
			col_direction=0
		fi
	done
done

declare -A visited_cases=(["$row_guard $col_guard"]=1)
row_front=$((row_guard + row_direction))
col_front=$((col_guard + col_direction))
i_direction=0
while true; do
	((row_guard += row_direction))
	((col_guard += col_direction))
	((row_front += row_direction))
	((col_front += col_direction))

	# out?
	((row_guard < 0 || row_guard >= n_rows || col_guard < 0 || col_guard >= n_cols)) && break
	visited_cases["$row_guard $col_guard"]=1
	# do you have an obstacle in front of you?
	[[ ! -v ${obstacle_positions["$row_front $col_front"]} ]] && continue
	
	((i_direction++))
	read -r row_direction col_direction <<<"${directions[i_direction % 4]}"

	((row_front = row_guard + row_direction))
	((col_front = col_guard + col_direction))
done

echo "${#visited_cases[@]}"
