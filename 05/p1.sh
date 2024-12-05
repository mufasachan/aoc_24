file_path=$1

sep_line=$(awk '/^$/ { print NR }' "$file_path")
n_lines=$(wc -l <"$file_path")

ordering_records=$(head -n $((sep_line)) "$file_path" | tr '\n' ' ')
declare -A before_to_after
for record in $ordering_records; do
	IFS='|' read -r before after <<<"$record"
	before_to_after["$before"]="$after ${before_to_after[$before]}"
done

updates=$(tail -n $((n_lines - sep_line)) "$file_path" | tr '\n' ' ')
score=0
for update in $updates; do
	IFS=',' read -ra records <<<"$update"
	is_correct=1
	for ((i = 1; i < ${#records[@]}; i++)); do
		record="${records[$i]}"
		befores="${before_to_after[$record]}"

		[[ -z $befores ]] && continue
		previous_records="${records[*]:0:$i}" 
		matches=$(echo "$previous_records" | tr ' ' '\n' | awk 'NR==FNR {a[$1];next} $1 in a' - <(echo "$befores" | tr ' ' '\n'))
		if [[ -n "$matches" ]]; then
			is_correct=0
			break
		fi
	done

	if [[ $is_correct == 1 ]]; then
		middle=$((${#records[@]} / 2))
		((score += records[middle]))
	fi
done
echo $score
