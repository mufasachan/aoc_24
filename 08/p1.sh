mapfile lines <"$1"
n="${#lines[@]}"

declare -A antenna_to_positions
for ((i = 0; i < n; i++)); do
	line="${lines[i]}"
	for ((j = 0; j < n; j++)); do
		char="${line:j:1}"
		[[ $char == '.' ]] && continue
		antenna_to_positions["$char"]+="$i,$j "
	done
done

declare -A antenna_locations
for antenna in "${!antenna_to_positions[@]}"; do
	_positions="${antenna_to_positions["$antenna"]}"
	read -ra positions<<<"${_positions[@]}"
	n_positions="${#positions[@]}"
	for ((i = 0; i < n_positions; i++)); do
		IFS=',' read -r x1 y1<<<"${positions[i]}"
		for (( j = i+1; j < n_positions; j++)); do
			IFS=',' read -r x2 y2<<<"${positions[j]}"

			((dx=x2-x1))
			((dy=y2-y1))

			((x3=x2+dx))
			((y3=y2+dy))
			((x4=x1-dx))
			((y4=y1-dy))
			if ((x3 >= 0 && x3 < n && y3 >= 0 && y3 < n )); then
				antenna_locations["$x3,$y3"]=1
			fi
			if ((x4 >= 0 && x4 < n && y4 >= 0 && y4 < n )); then
				antenna_locations["$x4,$y4"]=1
			fi
		done
	done
	
done

echo "${#antenna_locations[@]}"

