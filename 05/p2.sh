get_reordered_score() {
	local -a records
	IFS=',' read -ra records <<<"$1"
	local n_records="${#records[@]}"

	for ((i = n_records - 1; i > 0; i--)); do
		while true; do
			local record=${records[$i]}
			local previous_records=("${records[@]:0:$i}")

			# No after = it's in the write position!
			[[ -z "${before_to_afters["$record"]}" ]] && break

			local afters
			read -ra afters <<< "${before_to_afters["$record"]}"
			local n_afters=${#afters[@]}
			local n_previous=${#previous_records[@]}

			local is_correct=1
			for ((i_prev = 0; i_prev < n_previous; i_prev++)); do
				local previous_record=${previous_records[$i_prev]}
				for ((i_after = 0; i_after < n_afters; i_after++)); do
					if ((previous_record == afters[i_after])); then
						is_correct=0
						break
					fi
				done
				((is_correct == 0)) && break
			done
			# ((is_correct == 1)) && echo "-- correct ($i_prev,$i_after,$i)" >&2 || echo "-- not correct ($i_prev,$i_after,$i)" >&2

			if ((is_correct == 0)); then
				# Swap current record with its after
				local tmp=${records[$i_prev]}
				records[i_prev]=$record
				records[i]=$tmp
			else
				break
			fi

		done
	done
	echo "${records[$((n_records / 2))]}"
}
file_path=$1

sep_line=$(awk '/^$/ { print NR }' "$file_path")
n_lines=$(wc -l <"$file_path")

ordering_records=$(head -n $((sep_line)) "$file_path" | tr '\n' ' ')
declare -A before_to_afters
for record in $ordering_records; do
	IFS='|' read -r before after <<<"$record"
	before_to_afters["$before"]="$after ${before_to_afters[$before]}"
done

updates=$(tail -n $((n_lines - sep_line)) "$file_path" | tr '\n' ' ')
score=0
for update in $updates; do
	IFS=',' read -ra records <<<"$update"

	for ((i = 1; i < ${#records[@]}; i++)); do
		record="${records[$i]}"
		befores="${before_to_afters[$record]}"

		[[ -z $befores ]] && continue
		previous_records="${records[*]:0:$i}"
		match=$(echo "$previous_records" | tr ' ' '\n' | awk 'NR==FNR {a[$1];next} $1 in a' - <(echo "$befores" | tr ' ' '\n'))
		if [[ -n "$match" ]]; then
			score_reorder=$(get_reordered_score "$update")
			((score += score_reorder))
			break
		fi
	done
done
echo $score
