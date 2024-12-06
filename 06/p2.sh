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

score=0
for ((i = 3; i < ${#lines[@]}; i++)); do
	read -r x_current y1_current y2_current <<<"${lines[i]}"
	# + 1 because next directions, / 4 to count the number of turns
	((i_others_max = (i + 1) / 4))

	for ((i_other = 0; i_other < i_others_max; i_other++)); do
		((i_other_line = (i_other * 4) + ((i + 1) % 4)))
		read -r x_previous y1_previous y2_previous <<<"${lines[i_other_line]}"

		# Line is in a possible position
		((y2_current < x_previous || y1_current > x_previous)) && continue

		# Check that it is in correct side
		((i_direction = i % 4))
		if ((i_direction < 2)); then
			# up and right
			((x_current > y2_previous)) && continue
		else
			# down and left
			((x_current < y1_previous)) && continue
		fi

		# If the lines cross each other (Easy case)
		if ((y1_previous <= x_current && x_current <= y2_previous)); then
			((score++))
			continue
		fi

		((no_obstacle=1))
		((test=1))
		case $i_direction in
		0)  # Upward
			for obstacle_position in "${!obstacle_positions[@]}"; do
				read -r row_obstacle col_obstacle <<<"$obstacle_position"
				((x_previous != row_obstacle)) && continue
				if ((col_obstacle > x_current && col_obstacle < y1_previous)); then
					no_obstacle=0
					# if obstacle 
					break
				fi
			done
			((test--))
			;;
		1)  # to the right
			for obstacle_position in "${!obstacle_positions[@]}"; do
				read -r row_obstacle col_obstacle <<<"$obstacle_position"
				((x_previous != col_obstacle)) && continue
				if ((row_obstacle > x_current && row_obstacle < y1_previous)); then
					no_obstacle=0
					break
				fi
			done
			((test--))
			;;
		2)  # downward
			for obstacle_position in "${!obstacle_positions[@]}"; do
				read -r row_obstacle col_obstacle <<<"$obstacle_position"
				((x_previous != row_obstacle)) && continue
				if ((col_obstacle > y2_previous && col_obstacle < x_current)); then
					no_obstacle=0
					break
				fi
			done
			((test--))
			;;
		3)  # to the left
			for obstacle_position in "${!obstacle_positions[@]}"; do
				read -r row_obstacle col_obstacle <<<"$obstacle_position"
				((x_previous != col_obstacle)) && continue
				if ((row_obstacle > y2_previous && row_obstacle < x_current)); then
					no_obstacle=0
					break
				fi
			done
			((test--))
			;;
		esac

		if ((no_obstacle == 1)); then 
			((score++))
			continue
		fi

		# Maybe the obstacle leads to another path?
		# but this time we cannot block anymore the guard path
		# So compute the new path and maybe it will join a previous line.

	done
done

echo $score
