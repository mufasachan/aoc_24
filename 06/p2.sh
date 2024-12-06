get_line() {
	local direction=$1
	local row_guard=$2
	local col_guard=$3
	local row_last=$4
	local col_last=$5

	local line
	case "$direction" in
	"$BOT_TO_TOP")
		line="$col_guard $row_guard $row_last"
		;;
	"$TOP_TO_BOT")
		line="$col_guard $row_last $row_guard"
		;;
	"$LEFT_TO_RIGHT")
		line="$row_guard $col_last $col_guard"
		;;
	"$RIGHT_TO_LEFT")
		line="$row_guard $col_guard $col_last"
		;;
	esac

	echo "$line"
}

file_path=$1

# IFS=$'\n' read -ra map < "$file_path"
mapfile -t map <"$file_path"
n_rows=${#map[@]}
n_cols=${#map[0]}

declare obstacle_positions=""

declare -r BOT_TO_TOP="-1 0"
declare -r LEFT_TO_RIGHT="0 1"
declare -r TOP_TO_BOT="1 0"
declare -r RIGHT_TO_LEFT="0 -1"

declare -A obstacle_positions=()

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

row_front=$((row_guard + row_direction))
col_front=$((col_guard + col_direction))

row_last=$row_guard
col_last=$row_guard
declare -a lines=()

i_direction=0
while true; do
	((row_guard += row_direction))
	((col_guard += col_direction))
	((row_front += row_direction))
	((col_front += col_direction))

	# out?
	((row_guard < 0 || row_guard >= n_rows || col_guard < 0 || col_guard >= n_cols)) && break
	[[ ! -v ${obstacle_positions["$row_front $col_front"]} ]] && continue

	lines+=("$(get_line "$row_direction $col_direction" $row_guard $col_guard $row_last $col_last)")
	row_last=$row_guard
	col_last=$col_guard

	((i_direction++))
	read -r row_direction col_direction <<<"${directions[i_direction % 4]}"
	((row_front = row_guard + row_direction))
	((col_front = col_guard + col_direction))

done
# manage last line
lines+=("$(get_line "$row_direction $col_direction" $row_guard $col_guard $row_last $col_last)")

declare -A positions_deviation
declare -A lines_with_loop
for ((i = ${#lines[@]} - 1; i >= 0; i--)); do
	# 0: Upward, 1: Right, 2: Downward, 3: Left
	((direction_current = i % 4))
	line="${lines[i]}"
	read -r x_current y1_current y2_current <<<"$line"

	# Test other line that might a target line for deviation that loops
	for ((i_other = i; i_other >= 0; i_other--)); do
		((direction_other = i_other % 4))
		# Do not test the line with itself
		# Test only line with compatible direction
		((i == i_other || ((direction_current + 1) % 4) != direction_other)) && continue

		line_other="${lines[i_other]}"
		read -r x_other y1_other y2_other <<<"$line_other"

		# The future line is interesting only if it loops,
		# else they are just a fast-forward to the end.
		if ((i_other > i)); then
			[[ ! -v ${lines_with_loop["$line_other"]} ]] && continue
		fi

		# the other line is not reachable by a turn
		((y2_current < x_other || y1_current > x_other)) && continue

		# Check that it is in correct side
		if ((direction_current < 2)); then
			# up and right
			((x_current > y2_other)) && continue
		else
			# down and left
			((x_current < y1_other)) && continue
		fi

		# If the lines cross each other (Easy case)
		if ((y1_other <= x_current && x_current <= y2_other)); then
			case $direction_current in
			0)
				positions_deviation["$((x_other - 1)) $x_current"]=1
				;;
			1)
				positions_deviation["$x_current $((x_other + 1))"]=1
				;;
			2)
				positions_deviation["$((x_other + 1)) $x_current"]=1
				;;
			3)
				positions_deviation["$x_current $((x_other - 1))"]=1
				;;
			esac
			lines_with_loop["$line"]=1
			continue
		fi

		((no_obstacle = 1))
		case $direction_current in
		0) # Upward
			for obstacle_position in "${!obstacle_positions[@]}"; do
				read -r row_obstacle col_obstacle <<<"$obstacle_position"
				((x_other != row_obstacle)) && continue
				if ((col_obstacle > x_current && col_obstacle < y1_other)); then
					no_obstacle=0
					# if obstacle
					break
				fi
			done
			if ((no_obstacle == 1)); then
				positions_deviation["$((x_other - 1)) $x_current"]=1
				lines_with_loop["$line"]=1
			fi
			;;
		1) # to the right
			for obstacle_position in "${!obstacle_positions[@]}"; do
				read -r row_obstacle col_obstacle <<<"$obstacle_position"
				((x_other != col_obstacle)) && continue
				if ((row_obstacle > x_current && row_obstacle < y1_other)); then
					no_obstacle=0
					break
				fi
			done
			if ((no_obstacle == 1)); then
				positions_deviation["$x_current $((x_other + 1))"]=1
				lines_with_loop["$line"]=1
			fi
			;;
		2) # downward
			for obstacle_position in "${!obstacle_positions[@]}"; do
				read -r row_obstacle col_obstacle <<<"$obstacle_position"
				((x_other != row_obstacle)) && continue
				if ((col_obstacle > y2_other && col_obstacle < x_current)); then
					no_obstacle=0
					break
				fi
			done
			if ((no_obstacle == 1)); then
				positions_deviation["$((x_other + 1)) $x_current"]=1
				lines_with_loop["$line"]=1
			fi
			;;
		3) # to the left
			for obstacle_position in "${!obstacle_positions[@]}"; do
				read -r row_obstacle col_obstacle <<<"$obstacle_position"
				((x_other != col_obstacle)) && continue
				if ((row_obstacle > y2_other && row_obstacle < x_current)); then
					no_obstacle=0
					break
				fi
			done
			if ((no_obstacle == 1)); then
				positions_deviation["$x_current $((x_other - 1))"]=1
				lines_with_loop["$line"]=1
			fi
			;;
		esac

		# Maybe the obstacle leads to another path?
		# but this time we cannot block anymore the guard path
		# So compute the new path and maybe it will join a previous line.
	done
done

echo "${#positions_deviation[@]}"
