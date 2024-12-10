mapfile -t map <"$1"
n_rows=${#map[@]}
n_cols=${#map[0]}

declare -A obstacle_positions=()
declare -i row_guard col_guard
for ((i_row = 0; i_row < n_rows; i_row++)); do
	row="${map[i_row]}"
	for ((i_col = 0; i_col < n_cols; i_col++)); do
		element=${row:i_col:1}
		[[ "$element" == "#" ]] && obstacle_positions["$i_row,$i_col"]=1
		if [[ "$element" == "^" ]]; then
			row_guard=$i_row
			col_guard=$i_col
		fi
	done
done

((row_guard_start = row_guard))
((col_guard_start = col_guard))
((direction_start = 0))
((row_direction_start = -1))
((col_direction_start = 0))

((direction = direction_start))
((row_direction = row_direction_start))
((col_direction = col_direction_start))
((row_guard = row_guard_start))
((col_guard = col_guard_start))
((row_front = row_guard + row_direction))
((col_front = col_guard + col_direction))

declare -A visited_cases=()
while true; do
	((row_front < 0 || row_front >= n_rows || col_front < 0 || col_front >= n_cols)) && break

	if ((obstacle_positions["$row_front,$col_front"])); then
		((direction = (direction + 1) % 4))
		case "$direction" in
		"0")
			((row_direction = -1))
			((col_direction = 0))
			;;
		"1")
			((row_direction = 0))
			((col_direction = 1))
			;;
		"2")
			((row_direction = 1))
			((col_direction = 0))
			;;
		"3")
			((row_direction = 0))
			((col_direction = -1))
			;;
		esac
		((row_front = row_guard + row_direction))
		((col_front = col_guard + col_direction))
	fi

	((row_guard = row_front))
	((col_guard = col_front))
	visited_cases["$row_guard,$col_guard"]=1

	((row_front += row_direction))
	((col_front += col_direction))
done

declare -A obstacles_loop
for obstacle_position in "${!visited_cases[@]}"; do
	[[ "$obstacle_position" == "$row_guard_start,$col_guard_start" ]] && continue
	obstacle_positions[$obstacle_position]=1

	((direction = direction_start))
	((row_direction = row_direction_start))
	((col_direction = col_direction_start))
	((row_guard = row_guard_start))
	((col_guard = col_guard_start))
	((row_front = row_guard + row_direction))
	((col_front = col_guard + col_direction))

	declare -A cases_seen=()
	while true; do
		((row_front < 0 || row_front >= n_rows || col_front < 0 || col_front >= n_cols)) && break

		if ((obstacle_positions["$row_front,$col_front"])); then
			((direction = (direction + 1) % 4))
			case "$direction" in
			"0")
				((row_direction = -1))
				((col_direction = 0))
				;;
			"1")
				((row_direction = 0))
				((col_direction = 1))
				;;
			"2")
				((row_direction = 1))
				((col_direction = 0))
				;;
			"3")
				((row_direction = 0))
				((col_direction = -1))
				;;
			esac
			((row_front = row_guard + row_direction))
			((col_front = col_guard + col_direction))
			continue
		fi

		((row_guard = row_front))
		((col_guard = col_front))
		if ((cases_seen["$direction,$row_guard,$col_guard"])); then
			obstacles_loop[$obstacle_position]=1
			break
		fi
		cases_seen["$direction,$row_guard,$col_guard"]=1

		((row_front += row_direction))
		((col_front += col_direction))
	done

	unset "obstacle_positions[$obstacle_position]"
	unset cases_seen
done

echo "${#obstacles_loop[@]}"
