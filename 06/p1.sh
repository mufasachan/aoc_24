file_path=$1

mapfile -t map <"$file_path"
n_rows=${#map[@]}
n_cols=${#map[0]}

declare -A obstacle_positions=()
declare -i row_guard col_guard
for ((i_row = 0; i_row < n_rows; i_row++)); do
	row="${map[i_row]}"
	for ((i_col = 0; i_col < n_cols; i_col++)); do
		element=${row:i_col:1}
		[[ "$element" == "#" ]] && obstacle_positions["$i_row $i_col"]=1
		if [[ "$element" == "^" ]]; then
			row_guard=$i_row
			col_guard=$i_col
		fi
	done
done

direction=0
declare -A visited_cases=(["$row_guard $col_guard"]=1)
case "$direction" in
"0")
	((row_front = row_guard - 1))
	((col_front = col_guard))
	;;
"1")
	((row_front = row_guard))
	((col_front = col_guard + 1))
	;;
"2")
	((row_front = row_guard + 1))
	((col_front = col_guard))
	;;
"3")
	((row_front = row_guard))
	((col_front = col_guard - 1))
	;;
esac

while true; do
	# out next step?
	if ((row_front < 0 || row_front >= n_rows || col_front < 0 || col_front >= n_cols)); then
		break
	fi

	# Is there an obstacle?
	if [[ -v ${obstacle_positions["$row_front $col_front"]} ]]; then
		# Change direction
		((direction = (direction + 1) % 4))
		# Update the new front based on the new direction
		case "$direction" in
		"0")
			((row_front = row_guard - 1))
			((col_front = col_guard))
			;;
		"1")
			((row_front = row_guard))
			((col_front = col_guard + 1))
			;;
		"2")
			((row_front = row_guard + 1))
			((col_front = col_guard))
			;;
		"3")
			((row_front = row_guard))
			((col_front = col_guard - 1))
			;;
		esac
	fi

	# Go forward
	((row_guard = row_front))
	((col_guard = col_front))
	visited_cases["$row_guard $col_guard"]=1

	case "$direction" in
	"0")
		((row_front = row_guard - 1))
		((col_front = col_guard))
		;;
	"1")
		((row_front = row_guard))
		((col_front = col_guard + 1))
		;;
	"2")
		((row_front = row_guard + 1))
		((col_front = col_guard))
		;;
	"3")
		((row_front = row_guard))
		((col_front = col_guard - 1))
		;;
	esac
done

echo "${#visited_cases[@]}"
